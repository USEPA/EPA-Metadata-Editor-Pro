import os
import re
import arcpy
from arcpy import metadata as md
import xml.etree.ElementTree as ET
from copy import deepcopy
import sys


class Toolbox(object):
    def __init__(self):
        """Define the toolbox (the name of the toolbox is the name of the
        .pyt file)."""
        self.label = "EPA Pro Metadata Toolbox"
        self.alias = ""

        # List of tool classes associated with this toolbox
        self.tools = [upgradeTool,saveTemplate,importTool,deleteTool,cleanExportTool,editElement,editDates, mergeTemplate, exportISOTool, esriSync, keywords2tags]
        # self.tools = [upgradeTool,cleanupTool,exportISOTool,saveTemplate,importTool,deleteTool,cleanExportTool,editElement,editDates, mergeTemplate]


class upgradeTool(object):
    def __init__(self):
        """Define the tool (tool name is the name of the class)."""
        self.label = "EPA Upgrade FGDC to ArcGIS and Clean"
        self.description = "Use this tool to upgrade FGDC CSDGM records or clean up ArcGIS format metadata. This tool will check the metadata format and perform a standard FGDC CSDGM-to-ArcGIS upgrade with additional cleanup steps. Cleanup includes copying legacy UUIDs to the ISO-Compliant element and removing all legacy elements. The cleanup process is also compatible with ArcGIS Format records. Metadata is considered upgraded to ArcGIS format if /metadata/mdStanName = ArcGIS Metadata. Users can run this multiple times on records if they are unsure of the format or if legacy elements are present."
        self.canRunInBackground = False

    def getParameterInfo(self):
        """Define parameter definitions"""
        # first parameter

        param0 = arcpy.Parameter(
            displayName="Source Metadata",
            name="Source_Metadata",
            datatype="DEType",
            parameterType="Required",
            direction="Input",
            multiValue=True)

        param1 = arcpy.Parameter(
            displayName="Overwrite Source Record",
            name="Overwrite",
            datatype="GPBoolean",
            parameterType="Required",
            direction="Input"
        )
        param1.value = "True"

        param2 = arcpy.Parameter(
            displayName="Output Directory",
            name="Output_Metadata",
            datatype="DEFolder",
            parameterType="Optional",
            direction="Input")

        param3 = arcpy.Parameter(
            displayName="File Prefix",
            name="FilePrefix",
            datatype="GPString",
            parameterType="Optional",
            direction="Input"
        )
        param3.value = "upgrade_"

        params = [param0, param1, param2, param3]
        return params

    def isLicensed(self):
        """Set whether tool is licensed to execute."""
        return True

    def updateParameters(self, parameters):
        """Modify the values and properties of parameters before internal
        validation is performed.  This method is called whenever a parameter
        has been changed."""
        # if parameters[1].valueAsText:
        #     fileExtension = parameters[1].valueAsText[-4:].lower()
        #     if fileExtension != ".xml":
        #         parameters[1].value = parameters[1].valueAsText + ".xml"

        if parameters[1].value is True:
            parameters[2].enabled = 'False'
            parameters[3].enabled = 'False'
        else:
            parameters[2].enabled = 'True'
            parameters[3].enabled = 'True'

        return

    def updateMessages(self, parameters):
        """Modify the messages created by internal validation for each tool
        parameter.  This method is called after internal validation."""

        if parameters[1].value is False and parameters[2].value is None:
            parameters[2].setErrorMessage("Folder Required")

        if parameters[1].value is False and parameters[3].value is None:
            parameters[3].setErrorMessage("File Prefix Required")

        return

    def execute(self, parameters, messages):

        Target_Metadata = parameters[0].valueAsText

        try:

            overwrite_md = parameters[1].valueAsText
            messages.addMessage("overwrite_md: {}".format(overwrite_md))
            # messages.addMessage("Scratch: {}".format(arcpy.env.scratchFolder))
            # messages.addMessage("path {}".format(os.path.join(arcpy.env.scratchFolder, 'junk.xml')))
            scratch_folder = arcpy.env.scratchFolder
            output_dir = parameters[2].valueAsText
            output_prefix = parameters[3].valueAsText
            if not output_prefix:
                output_prefix = 'tmp_'
            if not output_dir:
                output_dir = arcpy.env.scratchFolder

            # messages.addMessage("outPrefix: {}, outdir: {}".format(output_prefix, output_dir))

            for t in str(Target_Metadata).split(";"):

                if ' ' in t:
                    messages.addWarningMessage('*Upgrade process skipped for {} due to space found in name'.format(t))
                    continue

                basename = re.sub('[^_0-9a-zA-Z]+', '', os.path.splitext(os.path.basename(t))[0])

                output_name = "{}{}.xml".format(output_prefix, basename)
                output_metadata = ""
                # output_metadata = os.path.join(output_dir, output_name)

                tool_file_path = os.path.dirname(os.path.realpath(__file__))
                EPAUpgradeCleanup_xslt = tool_file_path + r'\EPAUpgradeCleanup.xslt'

                source_md = md.Metadata(t)
                # Test that this metadata hasn't already been upgraded
                root = ET.fromstring(source_md.xml)

                # if no ArcGIS Elements - metadata has not been upgraded yet
                if not any((root.findall('Esri/ArcGISFormat'), root.findall('mdStanName'))):
                    messages.addMessage("Upgrading the metadata for {}".format(t))
                    # Process: Upgrade Metadata
                    source_md.upgrade('FGDC_CSDGM')

                else:
                    original_name = "{}{}.xml".format('_original_', basename)
                    clean_name = "{}{}.xml".format('_cleanOnly_', basename)
                    upgrade_name = "{}{}.xml".format('_upgradeClean_', basename)
                    source_md.saveAsXML(os.path.join(scratch_folder, original_name))
                    source_md.saveAsUsingCustomXSLT(os.path.join(scratch_folder, clean_name), EPAUpgradeCleanup_xslt)
                    tmp_md = md.Metadata(source_md.uri)
                    tmp_md.upgrade('FGDC_CSDGM')
                    tmp_md.saveAsUsingCustomXSLT(os.path.join(scratch_folder, upgrade_name), EPAUpgradeCleanup_xslt)

                    # source_md.saveAsXML(os.path.join(scratch_folder, backup_name))
                    messages.addWarningMessage('*Upgrade process skipped for {} since it is in ArcGIS 1.0 format. Cleaning up legacy elements and preserving the UUID...'.format(t))
                    messages.addMessage('Backups of the source metadata placed at: {} and named the following for additional review {} {} {}'\
                                        .format(scratch_folder, clean_name, original_name, upgrade_name))

                try:
                    final_xml = os.path.join(output_dir, output_name)
                    # messages.addMessage("Temp file: {}".format(final_xml))
                    messages.addMessage("Cleaning up legacy elements and preserving the UUID...")

                    root_temp = ET.fromstring(source_md.xml)
                    old_keywords = "dataIdInfo/themeKeys/thesaName/[resTitle='ISO 19115 Topic Category']/.."
                    if len(root_temp.findall(old_keywords)) > 0:
                        messages.addMessage("Removing Legacy Keywords")
                        try:
                            parent = root_temp.findall(old_keywords + "/..")[0]
                            for e in root_temp.findall(old_keywords):
                                parent.remove(e)
                        except Exception as remove_error:
                            messages.addWarningMessage('Error Removing Legacy Keywords: {}'.format(remove_error))
                        source_md.xml = ET.tostring(root_temp)

                    #Fix for EPA Keywords Section
                    messages.addMessage('fixing epa keywords section')
                    try:
                        # delete thesaName, thesaLang replace with complete components below
                        # old EPA keywords parent (themeKeys) component
                        epa_keys_parent_xp = "dataIdInfo/themeKeys/thesaName/[resTitle='EPA GIS Keyword Thesaurus']/.."
                        epa_keys_thesaLang_xp = "dataIdInfo/themeKeys/thesaName/[resTitle='EPA GIS Keyword Thesaurus']/../thesaLang"
                        epa_keys_parent = root_temp.find(epa_keys_parent_xp)
                        old_epa_keys_thesaLang = root_temp.find(epa_keys_thesaLang_xp)
                        epa_keys_thesaName_xp = "dataIdInfo/themeKeys/thesaName/[resTitle='EPA GIS Keyword Thesaurus']"
                        old_thesaName = root_temp.find(epa_keys_thesaName_xp)
                        if old_thesaName:
                            messages.addMessage('removing old thesaName')
                            messages.addMessage(old_thesaName)
                            epa_keys_parent.remove(old_thesaName)
                        if old_epa_keys_thesaLang:
                            messages.addMessage('removing old thesaLang')
                            epa_keys_parent.remove(old_epa_keys_thesaLang)
                        static_epa_keys_thesaName = '''
                        <thesaName xmlns="">
                            <resTitle>EPA GIS Keyword Thesaurus</resTitle>
                            <date>
                                <pubDate>2007-11-02</pubDate>
                            </date>
                            <citOnlineRes xmlns="">
                                <linkage>https://ofmpub.epa.gov/sor_internet/registry/termreg/searchandretrieve/taxonomies/search.do?search=&amp;searchString=&amp;taxonomyName=WBT%20-%20Geographic%20Locations</linkage>
                                <orFunct>
                                    <OnFunctCd value="002"/>
                                </orFunct>
                                <orName>EPA Metadata Technical Specification</orName>
                            </citOnlineRes>
                        </thesaName>
                        '''
                        static_epa_keys_thesaLang = '''
                        <thesaLang>
                            <languageCode value="eng"/>
                            <countryCode value="US"/>
                        </thesaLang>
                        '''
                        static_epa_keys_thesaName_element = ET.fromstring(static_epa_keys_thesaName)
                        static_epa_keys_thesaLang_element = ET.fromstring(static_epa_keys_thesaLang)
                        epa_keys_parent.append(deepcopy(static_epa_keys_thesaName_element))
                        epa_keys_parent.append(deepcopy(static_epa_keys_thesaLang_element))

                        # Fix Place Keywords
                        messages.addMessage('fixing place keywords section')
                        place_keys_parent_xp = "dataIdInfo/placeKeys/thesaName/[resTitle='EPA Place Names']/.."
                        place_keys_thesaLang_xp = "dataIdInfo/placeKeys/thesaName/[resTitle='EPA Place Names']/../thesaLang"
                        place_keys_parent = root_temp.find(place_keys_parent_xp)
                        old_place_keys_thesaLang = root_temp.find(place_keys_thesaLang_xp)
                        place_keys_thesaName_xp = "dataIdInfo/placeKeys/thesaName/[resTitle='EPA Place Names']"
                        old_thesaName = root_temp.find(place_keys_thesaName_xp)
                        if old_thesaName:
                            messages.addMessage('removing old thesaName')
                            messages.addMessage(old_thesaName)
                            place_keys_parent.remove(old_thesaName)
                        if old_place_keys_thesaLang:
                            messages.addMessage('removing old thesaLang')
                            place_keys_parent.remove(old_epa_keys_thesaLang)
                        static_place_keys_thesaName = '''
                        <thesaName xmlns="">
                            <resTitle>EPA Place Names</resTitle>
                            <date>
                                <pubDate>2015-01-31T00:00:00</pubDate>
                            </date>
                            <citOnlineRes xmlns="">
                                <linkage>https://ofmpub.epa.gov/sor_internet/registry/termreg/searchandretrieve/taxonomies/search.do?search=&amp;searchString=&amp;taxonomyName=WBT%20-%20Geographic%20Locations</linkage>
                                <orFunct>
                                    <OnFunctCd value="002"/>
                                </orFunct>
                                <orName>Web Taxonomy - Geographic Locations</orName>
                            </citOnlineRes>
                        </thesaName>
                        '''
                        static_place_keys_thesaLang = '''
                        <thesaLang>
                            <languageCode value="eng"/>
                            <countryCode value="US"/>
                        </thesaLang>
                        '''
                        static_place_keys_thesaName_element = ET.fromstring(static_place_keys_thesaName)
                        static_place_keys_thesaLang_element = ET.fromstring(static_place_keys_thesaLang)
                        if place_keys_parent:
                            place_keys_parent.append(deepcopy(static_place_keys_thesaName_element))
                            place_keys_parent.append(deepcopy(static_place_keys_thesaLang_element))

                        # Fix for User Keywords Section
                        messages.addMessage('fixing User keywords section')

                        user_keys_parent_xp = "dataIdInfo/themeKeys/thesaName/[resTitle='User']/.."
                        user_keys_thesaLang_xp = "dataIdInfo/themeKeys/thesaName/[resTitle='User']/../thesaLang"
                        user_keys_parent = root_temp.find(user_keys_parent_xp)
                        old_user_keys_thesaLang = root_temp.find(user_keys_thesaLang_xp)
                        user_keys_thesaName_xp = "dataIdInfo/themeKeys/thesaName/[resTitle='User']"
                        old_thesaName = root_temp.find(user_keys_thesaName_xp)
                        if old_thesaName:
                            messages.addMessage('removing old thesaName')
                            messages.addMessage(old_thesaName)
                            user_keys_parent.remove(old_thesaName)
                        if old_user_keys_thesaLang:
                            messages.addMessage('removing old thesaLang')
                            user_keys_parent.remove(old_user_keys_thesaLang)
                        static_user_keys_thesaName = '''
                        <thesaName>
                            <resTitle>User</resTitle>
                            <date>
                                <pubDate>2020-11-18</pubDate>
                            </date>
                        </thesaName>
                        '''
                        static_user_keys_thesaLang = '''
                        <thesaLang>
                            <languageCode value="eng"/>
                            <countryCode value="US"/>
                        </thesaLang>
                        '''
                        static_user_keys_thesaName_element = ET.fromstring(static_user_keys_thesaName)
                        static_user_keys_thesaLang_element = ET.fromstring(static_user_keys_thesaLang)
                        if user_keys_parent:
                            user_keys_parent.append(deepcopy(static_user_keys_thesaName_element))
                            user_keys_parent.append(deepcopy(static_user_keys_thesaLang_element))

                        # Fix for Program Codes Section
                        messages.addMessage('fixing Federal Program Code keywords section')

                        pcode_keys_parent_xp = "dataIdInfo/themeKeys/thesaName/[resTitle='Federal Program Inventory']/.."
                        pcode_keys_thesaLang_xp = "dataIdInfo/themeKeys/thesaName/[resTitle='Federal Program Inventory']/../thesaLang"
                        pcode_keys_parent = root_temp.find(pcode_keys_parent_xp)
                        old_pcode_keys_thesaLang = root_temp.find(pcode_keys_thesaLang_xp)
                        pcode_keys_thesaName_xp = "dataIdInfo/themeKeys/thesaName/[resTitle='Federal Program Inventory']"
                        old_thesaName = root_temp.find(pcode_keys_thesaName_xp)
                        if old_thesaName:
                            messages.addMessage('removing old thesaName')
                            messages.addMessage(old_thesaName)
                            pcode_keys_parent.remove(old_thesaName)
                        if old_pcode_keys_thesaLang:
                            messages.addMessage('removing old thesaLang')
                            pcode_keys_parent.remove(old_pcode_keys_thesaLang)
                        static_pcode_keys_thesaName = '''
                        <thesaName>
                            <resTitle>Federal Program Inventory</resTitle>
                            <date>
                                <pubDate>2013-09-16</pubDate>
                            </date>
                            <citOnlineRes>
                                <linkage>https://www.performance.gov/federalprograminventory</linkage>
                                <orFunct>
                                    <OnFunctCd value="002">
                                    </OnFunctCd>
                                </orFunct>
                                <orName>Federal Program Inventory</orName>
                            </citOnlineRes>
                        </thesaName>
                        '''
                        static_pcode_keys_thesaLang = '''
                        <thesaLang>
                            <languageCode value="eng"/>
                            <countryCode value="US"/>
                        </thesaLang>
                        '''
                        static_pcode_keys_thesaName_element = ET.fromstring(static_pcode_keys_thesaName)
                        static_pcode_keys_thesaLang_element = ET.fromstring(static_pcode_keys_thesaLang)
                        if pcode_keys_parent:
                            pcode_keys_parent.append(deepcopy(static_pcode_keys_thesaName_element))
                            pcode_keys_parent.append(deepcopy(static_pcode_keys_thesaLang_element))

                        # apply changes
                        source_md.xml = ET.tostring(root_temp)
                    except Exception as e:
                        messages.addWarningMessage(e)

                    source_md.saveAsUsingCustomXSLT(final_xml, EPAUpgradeCleanup_xslt)
                    # temp_temp = md.Metadata().importMetadata(source_md.uri, 'CUSTOM', EPAUpgradeCleanup_xslt)
                    output_metadata = final_xml
                    # if overwrite back to source :
                    if overwrite_md == 'true':
                        source_md.copy(md.Metadata(final_xml))
                        # if source is standalone .xml:
                        fileExtension = t[-4:].lower()
                        if fileExtension == ".xml":
                            try:
                                os.remove(source_md.uri)
                            except Exception as ee:
                                messages.addWarningMessage(ee)
                            source_md.saveAsXML(source_md.uri)
                        # otherwise if feature class:
                        else:
                            source_md.save()
                        output_metadata = source_md.uri

                except Exception as e:
                    messages.addWarningMessage(e)

                if arcpy.Exists(output_metadata):
                    messages.addMessage("Process complete - please review the output carefully before importing or harvesting.")
                    messages.addMessage("Output: {}".format(output_metadata))

                else:
                    messages.addWarningMessage("Error processing {}.".format(t))

        except:
            # Cycle through Geoprocessing tool specific errors
            for msg in range(0, arcpy.GetMessageCount()):
                if arcpy.GetSeverity(msg) == 2:
                    arcpy.AddReturnMessage(msg)
        finally:
            # Regardless of errors, clean up intermediate products.
            # scratchCopier.cleanupScratchCopy()
            pass
        return

class cleanupTool(object):
    def __init__(self):
        """Define the tool (tool name is the name of the class)."""
        self.label = "EPA Cleanup ArcGIS Record"
        self.description = "This tool performs several extra cleanup steps including copying legacy UUIDs to the ISO-Compliant element and cleaning up all legacy elements. This tool is recommended for records that have already been upgraded to ArcGIS Metadata."
        self.canRunInBackground = False

    def getParameterInfo(self):
        """Define parameter definitions"""
            # first parameter
        param0 = arcpy.Parameter(
            displayName="Source Metadata",
            name="Source_Metadata",
            datatype="DEType",
            parameterType="Required",
            direction="Input",
            multiValue=True)

        # # second parameter
        # param1 = arcpy.Parameter(
        #     displayName="Output Metadata",
        #     name="Output_Metadata",
        #     datatype="DEFile",
        #     parameterType="Required",
        #     direction="Output")
        # second parameter
        param1 = arcpy.Parameter(
            displayName="Output Directory",
            name="Output_Directory",
            datatype="DEFolder",
            parameterType="Required",
            direction="Input")

        params = [param0, param1]
        return params

    def isLicensed(self):
        """Set whether tool is licensed to execute."""
        return True

    def updateParameters(self, parameters):
        """Modify the values and properties of parameters before internal
        validation is performed.  This method is called whenever a parameter
        has been changed."""
        # if parameters[1].valueAsText:
        #     fileExtension = parameters[1].valueAsText[-4:].lower()
        #     if fileExtension != ".xml":
        #         parameters[1].value = parameters[1].valueAsText + ".xml"
        return

    def updateMessages(self, parameters):
        """Modify the messages created by internal validation for each tool
        parameter.  This method is called after internal validation."""
        return

    def execute(self, parameters, messages):
        try:
            """The source code of the tool."""
            Target_Metadata = parameters[0].valueAsText
            Output_Dir = parameters[1].valueAsText

            for t in str(Target_Metadata).split(";"):

                if ' ' in t:
                    messages.addWarningMessage('*Check results for {} due to space found in name'.format(t))
                    continue

                basename = re.sub('[^_0-9a-zA-Z]+', '', os.path.splitext(os.path.basename(t))[0])
                Output_Name = "_{}_cleanup.xml".format(basename)

                Output_Metadata = os.path.join(Output_Dir, Output_Name)
                messages.addMessage(Output_Metadata)

                source_md = md.Metadata(t)

                # Local variables:
                tool_file_path = os.path.dirname(os.path.realpath(__file__))
                EPAUpgradeCleanup_xslt = tool_file_path + r"\EPAUpgradeCleanup.xslt"

                messages.addMessage("Preserving the UUID and cleaning up legacy elements...")

                # Process: EPA Cleanup
                try:
                    source_md.saveAsUsingCustomXSLT(Output_Metadata, EPAUpgradeCleanup_xslt)
                    # Process: EPA Cleanup
                    # arcpy.XSLTransform_conversion(Upgraded_Metadata, EPAUpgradeCleanup_xslt, Output_Metadata, "")
                except Exception as e:
                    messages.addWarningMessage(e)

                if arcpy.Exists(Output_Metadata):
                    messages.addMessage("Process complete - please review the output carefully before importing or harvesting.")
                    messages.addMessage("Output: {}".format(Output_Metadata))

                else:
                    messages.addWarningMessage("Error Creating file.")

        except:
            # Cycle through Geoprocessing tool specific errors
            for msg in range(0, arcpy.GetMessageCount()):
                if arcpy.GetSeverity(msg) == 2:
                    arcpy.AddReturnMessage(msg)
        finally:
            # Regardless of errors, clean up intermediate products.
            pass
        return

class exportISOTool(object):
    def __init__(self):
        """Define the tool (tool name is the name of the class)."""
        self.label = "Export ArcGIS Metadata to ISO"
        self.description = "This tool streamlines exporting ArcGIS metadata to compliant ISO 19115, 19139. It is equivalent to using the Export Metadata tool yet allows for multiselect processing"
        self.canRunInBackground = False

    def getParameterInfo(self):
        """Define parameter definitions"""
            # first parameter
        param0 = arcpy.Parameter(
            displayName="Source Metadata",
            name="Source_Metadata",
            datatype="DEType",
            parameterType="Required",
            direction="Input",
            multiValue=True)

        # # second parameter
        # param1 = arcpy.Parameter(
        #     displayName="Output Metadata",
        #     name="Output_Metadata",
        #     datatype="DEFile",
        #     parameterType="Required",
        #     direction="Output")
        # second parameter
        param1 = arcpy.Parameter(
            displayName="Output Directory",
            name="Output_Dir",
            datatype="DEFolder",
            parameterType="Required",
            direction="Input")

        param2 = arcpy.Parameter(
            displayName="ISO Format",
            name="ISO_Format",
            parameterType="Required",
            direction="Input",
            datatype="GPString"
        )

        param2.filter.type = "ValueList"
        # param2.filter.list = ["FGDC_CSDGM", "ISO19139", "ISO19139_GML32", "ISO19115_3"]
        param2.filter.list = ["ISO19139", "ISO19139_GML32", "ISO19115_3"]
        param2.value = 'ISO19139'
        params = [param0, param1, param2]
        return params

    def isLicensed(self):
        """Set whether tool is licensed to execute."""
        return True

    def updateParameters(self, parameters):
        """Modify the values and properties of parameters before internal
        validation is performed.  This method is called whenever a parameter
        has been changed."""
        # if parameters[1].valueAsText:
        #     fileExtension = parameters[1].valueAsText[-4:].lower()
        #     if fileExtension != ".xml":
        #         parameters[1].value = parameters[1].valueAsText + ".xml"
        return

    def updateMessages(self, parameters):
        """Modify the messages created by internal validation for each tool
        parameter.  This method is called after internal validation."""
        return

    def execute(self, parameters, messages):
        try:
            # TODO: Update this tool for Pro's Parameters since multiple ISO formats accepted
            '''
            https://pro.arcgis.com/en/pro-app/arcpy/metadata/migrating-from-arcmap-to-arcgis-pro.htm
            '''
            """The source code of the tool."""
            Target_Metadata = parameters[0].valueAsText
            # messages.addMessage(Target_Metadata)
            Output_Dir = parameters[1].valueAsText
            ISO_format = parameters[2].valueAsText

            for t in str(Target_Metadata).split(";"):

                if ' ' in t:
                    messages.addWarningMessage('*Export skipped for {} due to space found in name'.format(t))
                    continue

                basename = re.sub('[^_0-9a-zA-Z]+', '', os.path.splitext(os.path.basename(t))[0])
                Output_Name = "export_{}_{}.xml".format(ISO_format, basename)
                Output_Metadata = os.path.join(Output_Dir, Output_Name)
                # messages.addMessage(t)
                messages.addMessage(Output_Metadata)
                messages.addMessage(ISO_format)

                # Local variables:
                # messages.addMessage('Install Dir: {}'.format(arcpy.GetInstallInfo()['InstallDir']))
                # translator = arcpy.GetInstallInfo()['InstallDir'] + "Metadata\\Translator\\ArcGIS2ISO19139.xml"

                src_md = md.Metadata(t)
                # generate output path from input name
                src_md.exportMetadata(outputPath=Output_Metadata, metadata_export_option=ISO_format)

                if arcpy.Exists(Output_Metadata):
                    messages.addMessage("Process complete - please review the output carefully before importing or harvesting.")
                    messages.addMessage("Output: {}".format(Output_Metadata))
                else:
                    messages.addWarningMessage("Error Creating output.")

        except:
            # Cycle through Geoprocessing tool specific errors
            for msg in range(0, arcpy.GetMessageCount()):
                if arcpy.GetSeverity(msg) == 2:
                    arcpy.AddReturnMessage(msg)
        finally:
            # Regardless of errors, clean up intermediate products.
            pass
        return

class saveTemplate(object):
    def __init__(self):
        """Define the tool (tool name is the name of the class)."""
        self.label = "Save record as metadata template"
        self.description = "This tool saves a metadata record as a reusable template by excluding those elements which must be unique in every metadata record, such as title, abstract, unique identifier, etc, leaving those elements that are common across many records."
        self.canRunInBackground = False

    def getParameterInfo(self):
        """Define parameter definitions"""
        param0 = arcpy.Parameter(
            displayName="Source Metadata",
            name="Source_Metadata",
            datatype="DEType",
            parameterType="Required",
            direction="Input",
            multiValue=True)

        # param1 = arcpy.Parameter(
        #     displayName="Output Metadata",
        #     name="Output_Metadata",
        #     datatype="DEFile",
        #     parameterType="Required",
        #     direction="Output")
        param1 = arcpy.Parameter(
            displayName="Output Directory",
            name="Output_Dir",
            datatype="DEFolder",
            parameterType="Required",
            direction="Input")

        params = [param0, param1]
        return params

    def isLicensed(self):
        """Set whether tool is licensed to execute."""
        return True

    def updateParameters(self, parameters):
        """Modify the values and properties of parameters before internal
        validation is performed.  This method is called whenever a parameter
        has been changed."""
        # if parameters[1].valueAsText:
        #     fileExtension = parameters[1].valueAsText[-4:].lower()
        #     if fileExtension != ".xml":
        #         parameters[1].value = parameters[1].valueAsText + ".xml"
        return

    def updateMessages(self, parameters):
        """Modify the messages created by internal validation for each tool
        parameter.  This method is called after internal validation."""
        return

    def execute(self, parameters, messages):
        try:
            """The source code of the tool."""
            tool_file_path = os.path.dirname(os.path.realpath(__file__))

            Target_Metadata = parameters[0].valueAsText
            messages.addMessage(Target_Metadata)
            Output_Dir = parameters[1].valueAsText

            for t in str(Target_Metadata).split(";"):
                if ' ' in t:
                    messages.addWarningMessage('*Check results for {} due to space found in name'.format(t))
                    continue

                basename = re.sub('[^_0-9a-zA-Z]+', '', os.path.splitext(os.path.basename(t))[0])
                Output_Name = "_{}_template.xml".format(basename)
                Output_Metadata = os.path.join(Output_Dir, Output_Name)
                # messages.addMessage(f'param 1 {Output_Metadata}')

                source_md = md.Metadata(t)

                # Local variables:
                saveTemplate_xslt = tool_file_path + r"\saveTemplate.xslt"

                # Process: EPA Cleanup
                try:
                    # arcpy.XSLTransform_conversion(Source_Metadata, saveTemplate_xslt, Output_Metadata, "")
                    source_md.saveAsUsingCustomXSLT(Output_Metadata, saveTemplate_xslt)
                except Exception as e:
                    messages.addWarningMessage(e)

                if arcpy.Exists(Output_Metadata):
                    messages.addMessage("Process complete - please review the output carefully before reusing as a template.")
                    messages.addMessage("Output: {}".format(Output_Metadata))
                else:
                    messages.addWarningMessage("Error Creating file.")

        except:
            # Cycle through Geoprocessing tool specific errors
            for msg in range(0, arcpy.GetMessageCount()):
                if arcpy.GetSeverity(msg) == 2:
                    arcpy.AddReturnMessage(msg)
        finally:
            # Regardless of errors, clean up intermediate products.
            pass
        return
# For sync tool, might need to look at a handful of elements that need to have the sync attribute
# set to true, or remove the tag. e.g., Data Quality Bounding Box (might not even get sync'd)
# or other nested elements

class mergeTemplate(object):
    def __init__(self):
        """Define the tool (tool name is the name of the class)."""
        self.label = "Merge a selected metadata record with a saved template"
        self.description = "This tool replaces the elements in a metadata record with elements from a saved template record. Elements from the template will overwrite their equivalents in the selected record based on the xpath rules provided in GenericTemplateXpathSettings.xml. The provided template (GenericMetadataTemplate_EMEPro.xml) can be used as a custom Set-To-Default tool. Both files are deployed with the python tool. Caution is urged when using this tool."
        self.canRunInBackground = False

    def getParameterInfo(self):
        """Define parameter definitions"""

        param0 = arcpy.Parameter(
            displayName="Target Metadata",
            name="Target_Metadata",
            datatype="DEType",
            parameterType="Required",
            direction="Input",
            multiValue=True)

        param1 = arcpy.Parameter(
            displayName="Template Metadata",
            name="Template_Metadata",
            datatype="DEFile",
            parameterType="Required",
            direction="Input")
        param1.value = os.path.dirname(os.path.realpath(__file__)) + r"\GenericMetadataTemplate_EMEPro.xml"

        # param2 = arcpy.Parameter(
        #     displayName="Update Elements",
        #     name="Xpath_Expression",
        #     datatype="GPString",
        #     parameterType="Optional",
        #     direction="Input",
        #     multiValue=True
        # )
        # # param2.value = ["dataIdInfo/idCitation/resTitle","dataIdInfo/idAbs","dataIdInfo/idPurp"]
        # param2.value = [".//dataIdInfo/resConst", ".//dataIdInfo/themeKeys/thesaName/[resTitle='EPA GIS Keyword Thesaurus']/..", "mdLang"]

        params = [param0, param1]
        return params

    def isLicensed(self):
        """Set whether tool is licensed to execute."""
        return True

    def updateParameters(self, parameters):
        """Modify the values and properties of parameters before internal
        validation is performed.  This method is called whenever a parameter
        has been changed."""
        # if parameters[2].valueAsText:
        #     fileExtension = parameters[2].valueAsText[-4:].lower()
        #     if fileExtension != ".xml":
        #         parameters[2].value = parameters[2].valueAsText + ".xml"

        return

    def updateMessages(self, parameters):
        """Modify the messages created by internal validation for each tool
        parameter.  This method is called after internal validation."""

        return

    def execute(self, parameters, messages):

        # messages.addMessage("Setting Defaults...")
        tool_file_path = os.path.dirname(os.path.realpath(__file__))

        try:
            """The source code of the tool."""
            Template_Metadata = parameters[1].valueAsText
            template_md = md.Metadata(Template_Metadata)
            Target_Metadata = parameters[0].valueAsText

            try:
                defaults_xpath = ET.parse(tool_file_path + r"\GenericTemplateXpathSettings.xml")
                defaults_xpath_list = defaults_xpath.getroot().findall("ElementName[IsDefault='true']")
            except Exception as parse_error:
                messages.addWarningMessage("Error Parsing GenericTemplateXpathSettings.xml {}".format(parse_error))

            # xpath_list = parameters[2].valueAsText
            # xpath_list = ["dataIdInfo/idPoC/role/RoleCd[@value='010']/../..","dataIdInfo/resConst", ".//dataIdInfo/themeKeys/thesaName/[resTitle='EPA GIS Keyword Thesaurus']/..", "mdLang"]

            for t in str(Target_Metadata).split(';'):
                if ' ' in t:
                    messages.addWarningMessage('*Merge process skipped for {} due to space found in name'.format(t))
                    continue

                messages.addMessage("Processing Target {}".format(t))

                source_md = md.Metadata(t)
                source_root = ET.fromstring(source_md.xml)
                template_root = ET.fromstring(template_md.xml)
                # messages.addMessage("starting xpath loop")
                for xp in defaults_xpath_list:
                    try:
                        # messages.addMessage("First one {}".format(xp[0].text))
                        if len(template_root.findall(xp[0].text)) > 0:
                            messages.addMessage('- Found in template {}: {}'.format(xp[1].text, xp[0].text))
                            # Remove source data
                            if len(source_root.findall(xp[0].text)) > 0:
                                parent = source_root.findall(xp[0].text + "/..")[0]
                                try:
                                    for e in source_root.findall(xp[0].text):
                                        parent.remove(e)
                                        messages.addMessage('- Removed old target element: {}: {}'.format(xp[1].text, xp[0].text))
                                except Exception as ee:
                                    messages.addWarningMessage(ee)

                            # Build out the list of req'd nodes leading up to the parent. Use template_md
                            node_list = []
                            current_node_path = xp[0].text
                            current_node_tag = template_root.findall(xp[0].text)[0].tag
                            parent_node_path = ""
                            while current_node_tag != 'metadata':
                                current_node_path += "/.."
                                parent = template_root.findall(current_node_path)
                                if parent:
                                    if not parent[0].tag == 'metadata':
                                        node_list.insert(0, parent[0].tag)
                                    current_node_tag = parent[0].tag
                                else:
                                    #this should never happend, but just in case
                                    current_node_tag = 'metadata'
                                    messages.addMessage('This should not happen')

                            # node_list does not include root node, since that should always exist
                            source_parent_node = source_root
                            if node_list:
                                parent_node_path = "/".join(node_list)
                                # messages.addMessage('Parent Xpath: {}'.format(parent_node_path))
                                xpathList = []
                                thisNode = source_root
                                for xpathElem in node_list:
                                    xpathList.append(xpathElem)
                                    buildXPath = "/".join(xpathList)
                                    if len(source_root.findall(buildXPath)) == 0:
                                        ET.SubElement(thisNode, xpathElem)
                                    thisNode = source_root.findall(buildXPath)[0]
                                source_parent_node = source_root.findall(parent_node_path)[0]

                            for template_element in template_root.findall(xp[0].text):
                                try:
                                    source_parent_node.append(deepcopy(template_element))
                                    messages.addMessage('- Copied to target: {}: {}'.format(xp[1].text, xp[0].text))
                                except Exception as ee:
                                    messages.addWarningMessage(ee)
                    except Exception as err:
                        messages.addWarningMessage("Error: {}".format(err))

                source_md.xml = ET.tostring(source_root)

                try:
                    fileExtension = t[-4:].lower()
                    if fileExtension == ".xml":
                        try:
                            os.remove(source_md.uri)
                        except Exception as ee:
                            messages.addWarningMessage(ee)

                        source_md.saveAsXML(source_md.uri)
                    else:
                        source_md.save()

                except Exception as e:
                    messages.addMessage(e)

                if arcpy.Exists(t):
                    messages.addMessage("- Process complete - please review the output carefully.")
                    messages.addMessage("- Output: {}".format(t))

                else:
                    messages.addWarningMessage("Error processing {}.".format(t))

            messages.addMessage("Copy From Template Complete.")
        except:
            # Cycle through Geoprocessing tool specific errors
            for msg in range(0, arcpy.GetMessageCount()):
                if arcpy.GetSeverity(msg) == 2:
                    arcpy.AddReturnMessage(msg)
        finally:
            # messages.addMessage("Finally.")
            # Regardless of errors, clean up intermediate products.
            pass
        return


class esriSync(object):
    def __init__(self):
        """Define the tool (tool name is the name of the class)."""
        self.label = "Esri Synchronize"
        self.description = "This tool uses Esri's Metadata Synchronizer with additional options availble only via python. Please refer to Esri's tool documentation for details."
        self.canRunInBackground = False

    def getParameterInfo(self):
        """Define parameter definitions"""

        param0 = arcpy.Parameter(
            displayName="Target Feature Class",
            name="Target_Metadata",
            datatype="DEFeatureClass",
            parameterType="Required",
            direction="Input",
            multiValue=True)

        param1 = arcpy.Parameter(
            displayName="Synchronize Option",
            name="SyncOption",
            datatype="GPString",
            parameterType="Required",
            direction="Input"
        )
        param1.filter.type = "ValueList"
        param1.filter.list = ["SELECTIVE", "OVERWRITE"]
        param1.value = "SELECTIVE"

        params = [param0, param1]
        return params

    def isLicensed(self):
        """Set whether tool is licensed to execute."""
        return True

    def updateParameters(self, parameters):
        """Modify the values and properties of parameters before internal
        validation is performed.  This method is called whenever a parameter
        has been changed."""
        # if parameters[2].valueAsText:
        #     fileExtension = parameters[2].valueAsText[-4:].lower()
        #     if fileExtension != ".xml":
        #         parameters[2].value = parameters[2].valueAsText + ".xml"

        return

    def updateMessages(self, parameters):
        """Modify the messages created by internal validation for each tool
           parameter.  This method is called after internal validation."""

        return

    def execute(self, parameters, messages):

        messages.addMessage("Synchronizing Metadata...")

        try:
            """The source code of the tool."""

            Target_Metadata = parameters[0].valueAsText
            sync_option = parameters[1].valueAsText

            #ToDo: Start Loop here for multiple source MDs
            for t in str(Target_Metadata).split(';'):
                if ' ' in t:
                    messages.addWarningMessage('*Sync process skipped for {} due to space found in name'.format(t))
                    continue

                target_md = md.Metadata(t)
                try:
                    target_md.synchronize(metadata_sync_option=sync_option)
                except Exception as syncError:
                    messages.addWarningMessage(syncError)
                try:
                    target_md.save()
                    messages.addMessage("-  {} Synchronize complete for {}.".format(sync_option, t))
                except Exception as saveError:
                    messages.addWarningMessage(saveError)

            messages.addMessage("Process complete - please review the output carefully.")
        except:
            # Cycle through Geoprocessing tool specific errors
            for msg in range(0, arcpy.GetMessageCount()):
                if arcpy.GetSeverity(msg) == 2:
                    arcpy.AddReturnMessage(msg)
        finally:
            # messages.addMessage("Finally.")
            # Regardless of errors, clean up intermediate products.
            pass
        return

class deleteTool(object):
    def __init__(self):
        """Define the tool (tool name is the name of the class)."""
        self.label = "EPA Clear Record"
        self.description = "It is not unusual for the default Esri tools to merge and preserve legacy metadata sections when performing a standard import. This tool purges all metadata from the target (usually a feature class)."
        self.canRunInBackground = False

    def getParameterInfo(self):
        """Define parameter definitions"""
            # Second parameter
        param0 = arcpy.Parameter(
            displayName="Target Metadata",
            name="Target_Metadata",
            datatype="DEType",
            parameterType="Required",
            direction="Input",
            multiValue=True)

        params = [param0]
        return params

    def isLicensed(self):
        """Set whether tool is licensed to execute."""
        return True

    def updateParameters(self, parameters):
        """Modify the values and properties of parameters before internal
        validation is performed.  This method is called whenever a parameter
        has been changed."""
        return

    def updateMessages(self, parameters):
        """Modify the messages created by internal validation for each tool
        parameter.  This method is called after internal validation."""
        return

    def execute(self, parameters, messages):
        try:
            """The source code of the tool."""
            # Target_Metadata = sys.argv[1]
            Target_Metadata = parameters[0].valueAsText
            # messages.addMessage("Got the Target")
            # messages.addMessage("Target {}".format(Target_Metadata))
            # messages.addMessage("Parameter {}".format(parameters[0].value))

            # Local variables:
            # blankDoc = "blankdoc.xml" This no longer needed
            source_md = md.Metadata()
            # messages.addMessage("Got the blank")

            for t in str(Target_Metadata).split(";"):

                messages.addMessage("Performing complete purge of {}".format(t))
                # Process: Purge
                # arcpy.MetadataImporter_conversion(blankDoc, Target_Metadata)
                target_md = md.Metadata(t)

                fileExtension = t[-4:].lower()
                if fileExtension == ".xml":
                    try:
                        os.remove(t)
                    except Exception as ee:
                        messages.addWarningMessage(ee)
                    source_md.saveAsXML(target_md.uri)
                else:
                    try:
                        target_md.copy(source_md)
                        target_md.save()
                    except Exception as ee:
                        messages.addWarningMessage(ee)

                messages.addMessage("Process complete - please review the output carefully.")

        except:
            # Cycle through Geoprocessing tool specific errors
            for msg in range(0, arcpy.GetMessageCount()):
                if arcpy.GetSeverity(msg) == 2:
                    arcpy.AddReturnMessage(msg)
        finally:
            # Regardless of errors, clean up intermediate products.
            pass
        return

class importTool(object):
    def __init__(self):
        """Define the tool (tool name is the name of the class)."""
        self.label = "EPA Import ArcGIS Record"
        self.description = "It is not unusual for the default Esri tools to merge and preserve legacy metadata sections when performing a standard import. This tool first purges all metadata from the target (usually a feature class), then performs a clean import of the source. It does not perform the EPA upgrade or cleanup function, but rather is intended to supplement those tools and allow for a clean import of the output from those tools into a feature class."
        self.canRunInBackground = False

    def getParameterInfo(self):
        """Define parameter definitions"""
            # Second parameter
        param0 = arcpy.Parameter(
            displayName="Source Metadata",
            name="Source_Metadata",
            datatype="DEType",
            parameterType="Required",
            direction="Input")

        # Third parameter
        param1 = arcpy.Parameter(
            displayName="Target Metadata",
            name="Target_Metadata",
            datatype="DEType",
            parameterType="Required",
            direction="Input",
            multiValue=True)

        params = [param0, param1]
        return params

    def isLicensed(self):
        """Set whether tool is licensed to execute."""
        return True

    def updateParameters(self, parameters):
        """Modify the values and properties of parameters before internal
        validation is performed.  This method is called whenever a parameter
        has been changed."""
        return

    def updateMessages(self, parameters):
        """Modify the messages created by internal validation for each tool
        parameter.  This method is called after internal validation."""
        return

    def execute(self, parameters, messages):
        try:
            """The source code of the tool."""
            Source_Metadata = parameters[0].valueAsText
            Target_Metadata = parameters[1].valueAsText
            source_md = md.Metadata(Source_Metadata)

            # Local variables:
            # blankDoc = "blankdoc.xml"
            # blank_md = md.Metadata(blankDoc)

            messages.addMessage("Importing new metadata")
            for t in str(Target_Metadata).split(";"):

                target_md = md.Metadata(t)

                fileExtension = t[-4:].lower()
                if fileExtension == ".xml":
                    try:
                        os.remove(t)
                    except Exception as ee:
                        messages.addWarningMessage(ee)
                    source_md.saveAsXML(target_md.uri)
                else:
                    try:
                        target_md.copy(source_md)
                        target_md.save()
                        # TODO: Should probably sync if it is a feature class. Need to check if FC
                        # target_md.synchronize('SELECTIVE')
                    except Exception as ee:
                        messages.addWarningMessage(ee)

                messages.addMessage("Process complete - please review the output carefully.")
                messages.addMessage("Output: {}".format(t))

        except:
            # Cycle through Geoprocessing tool specific errors
            for msg in range(0, arcpy.GetMessageCount()):
                if arcpy.GetSeverity(msg) == 2:
                    arcpy.AddReturnMessage(msg)
        finally:
            # Regardless of errors, clean up intermediate products.
            pass
        return

class cleanExportTool(object):
    def __init__(self):
        """Define the tool (tool name is the name of the class)."""
        self.label = "EPA Clean Export Tool"
        self.description = "Most Esri metadata tools perform some sort of transformation on a metadata record when exporting to a standalone XML document. This tool allows a metadata record to be exported as-is with no transformations."
        self.canRunInBackground = False

    def getParameterInfo(self):
        """Define parameter definitions"""
            # first parameter
        param0 = arcpy.Parameter(
            displayName="Source Metadata",
            name="Source_Metadata",
            datatype="DEType",
            parameterType="Required",
            direction="Input",
            multiValue=True)

        # second parameter
        # param1 = arcpy.Parameter(
        #     displayName="Output Metadata",
        #     name="Output_Metadata",
        #     datatype="DEFile",
        #     parameterType="Required",
        #     direction="Output")
        param1 = arcpy.Parameter(
            displayName="Output Directory",
            name="Output_Dir",
            datatype="DEFolder",
            parameterType="Required",
            direction="Input")

        param2 = arcpy.Parameter(
            displayName="File Prefix",
            name="FilePrefix",
            datatype="GPString",
            parameterType="Required",
            direction="Input"
        )
        param2.value = "clean_export_"

        params = [param0, param1, param2]
        return params

    def isLicensed(self):
        """Set whether tool is licensed to execute."""
        return True

    def updateParameters(self, parameters):
        """Modify the values and properties of parameters before internal
        validation is performed.  This method is called whenever a parameter
        has been changed."""
        # if parameters[1].valueAsText:
        #     fileExtension = parameters[1].valueAsText[-4:].lower()
        #     if fileExtension != ".xml":
        #         parameters[1].value = parameters[1].valueAsText + ".xml"
        return

    def updateMessages(self, parameters):
        """Modify the messages created by internal validation for each tool
        parameter.  This method is called after internal validation."""
        return

    def execute(self, parameters, messages):
        try:
            """The source code of the tool."""

            tool_file_path = os.path.dirname(os.path.realpath(__file__))
            Target_Metadata = parameters[0].valueAsText
            Output_Dir = parameters[1].valueAsText
            output_prefix = parameters[2].valueAsText

            # Local variables:
            # blankDoc = "blankdoc.xml"
            # blank_md = md.Metadata(blankDoc)

            for t in str(Target_Metadata).split(";"):

                if ' ' in t:
                    messages.addWarningMessage('*Check results for {} due to space found in name'.format(t))
                    continue

                basename = re.sub('[^_0-9a-zA-Z]+', '', os.path.splitext(os.path.basename(t))[0])


                Output_Name = "{}{}.xml".format(output_prefix, basename)
                Output_Metadata = os.path.join(Output_Dir, Output_Name)

                source_md = md.Metadata(t)

                # Local variables:
                EPACleanExport_xslt = tool_file_path + r"\EPACleanExport.xslt"

                messages.addMessage("Exporting the metadata record...")
                # Process: EPA Cleanup
                try:
                    source_md.saveAsUsingCustomXSLT(Output_Metadata, EPACleanExport_xslt)
                except Exception as e:
                    messages.addWarningMessage(e)
                # # arcpy.XSLTransform_conversion(Source_Metadata, EPACleanExport_xslt, Output_Metadata, "")

                if arcpy.Exists(Output_Metadata):
                    messages.addMessage("Process complete - please review the output carefully before importing or harvesting.")
                    messages.addMessage("Output: {}".format(Output_Metadata))

                else:
                    messages.addWarningMessage("Error Creating file.")

        except:
            # Cycle through Geoprocessing tool specific errors
            for msg in range(0, arcpy.GetMessageCount()):
                if arcpy.GetSeverity(msg) == 2:
                    arcpy.AddReturnMessage(msg)
        finally:
            # Regardless of errors, clean up intermediate products.
            pass
        return

class editElement(object):
    def __init__(self):
        """Define the tool (tool name is the name of the class)."""
        self.label = "Edit Single XML Element Tool"
        self.description = "This tool accepts an XML XPath expression and a text value to update just a single element. If the element does not exist, it will be added. Please be aware that the source metadata will be changed - make a backup copy if necessary."
        self.canRunInBackground = False

    def getParameterInfo(self):
        """Define parameter definitions"""
        param0 = arcpy.Parameter(
            displayName="Target Metadata",
            name="Target_Metadata",
            datatype="DEType",
            parameterType="Required",
            direction="Input",
            multiValue=True
            )

        # Third parameter
        param1 = arcpy.Parameter(
            displayName="XPath Expression",
            name="Xpath_Expression",
            datatype="GPString",
            parameterType="Required",
            direction="Input")

        param2 = arcpy.Parameter(
            displayName="New Value",
            name="New_Value",
            datatype="GPString",
            parameterType="Required",
            direction="Input")

        params = [param0, param1, param2]
        return params

    def isLicensed(self):
        """Set whether tool is licensed to execute."""
        return True

    def updateParameters(self, parameters):
        """Modify the values and properties of parameters before internal
        validation is performed.  This method is called whenever a parameter
        has been changed."""
        return

    def updateMessages(self, parameters):
        """Modify the messages created by internal validation for each tool
        parameter.  This method is called after internal validation."""
        return

    def execute(self, parameters, messages):
        try:
            """The source code of the tool."""
            Target_Metadata = parameters[0].valueAsText
            Xpath_Expression = parameters[1].valueAsText
            New_Value = parameters[2].valueAsText

            for t in str(Target_Metadata).split(";"):

                target_md = md.Metadata(t)
                # scratch_md = md.Metadata()
                # scratch_md.copy(target_md)

                # Use scratchCopy class to make a standalone XML doc to work with.
                # scratchCopier = scratchCopy(messages)
                # scratch_Metadata = scratchCopier.makeScratchCopy(Target_Metadata)

                messages.addMessage("Editing the metadata record...")
                # Process: EPA Cleanup
                # tree = ET.parse(scratch_Metadata)
                # root = tree.getroot()
                # at the root when parsing from string
                root = ET.fromstring(target_md.xml)

                # This section iterates through the xpath components, adding any missing SubElements so there's at least one element to populate.
                xpathElements = Xpath_Expression.split("/")
                xpathList = []
                thisNode = root
                for xpathElem in xpathElements:
                    xpathList.append(xpathElem)
                    buildXPath = "/".join(xpathList)
                    if len(root.findall(buildXPath)) == 0:
                        ET.SubElement(thisNode,xpathElem)
                    thisNode = root.findall(buildXPath)[0]

                # This section updates the values of any matching xpath expressions
                elements = root.findall(Xpath_Expression)
                for elem in elements:
                    elem.text = New_Value

                # tree.write(scratch_Metadata)
                # messages.addMessage("writing back to xml object")

                target_md.xml = ET.tostring(root)

                fileExtension = t[-4:].lower()
                if fileExtension == ".xml":
                    try:
                        os.remove(target_md.uri)
                    except Exception as ee:
                        messages.addWarningMessage(ee)
                    target_md.saveAsXML(target_md.uri)
                else:
                    try:
                        target_md.save()
                    except Exception as ee:
                        messages.addWarningMessage(ee)

                messages.addMessage("Process complete, element update count: {}.".format(str(len(elements))))
                messages.addMessage("Output: {}".format(t))

                # If the target is a standalone XML doc, just copy the scratch over the source file.
                # if Target_Metadata[-4:].lower() == ".xml":
                #     import shutil
                #     shutil.copy(scratch_Metadata,Target_Metadata)
                # else:
                #     # Otherwise import the scratch metadata back to the source data.
                #     importer = importTool()
                #     importParams = importer.getParameterInfo()
                #     import_source = importParams[0]
                #     import_source.value = scratch_Metadata
                #     import_target = importParams[1]
                #     import_target.value = Target_Metadata
                #
                #     importer.execute([import_source,import_target],messages)

        except:
            # Cycle through Geoprocessing tool specific errors
            for msg in range(0, arcpy.GetMessageCount()):
                if arcpy.GetSeverity(msg) == 2:
                    arcpy.AddReturnMessage(msg)
        finally:
            # Regardless of errors, clean up intermediate products.
            # scratchCopier.cleanupScratchCopy()
            pass
        return

class editDates(object):
    def __init__(self):
        """Define the tool (tool name is the name of the class)."""
        self.label = "Edit Metadata Dates Tool"
        self.description = "This tool assists with editing the citation date values in ArcGIS Metadata to ease automated refreshes."
        self.canRunInBackground = False

    def getParameterInfo(self):
        """Define parameter definitions"""
        param0 = arcpy.Parameter(
            displayName="Target Metadata",
            name="Target_Metadata",
            datatype="DEType",
            parameterType="Required",
            direction="Input",
            multiValue=True)

        # Third parameter
        param1 = arcpy.Parameter(
            displayName="Date Option",
            name="Date_Label",
            datatype="GPString",
            parameterType="Required",
            direction="Input")
        param1.filter.type = "ValueList"
        param1.filter.list = ["Publication Date", "Creation Date", "Revision Date"]
        param1.value = "Revision Date"

        param2 = arcpy.Parameter(
            displayName="Date Value",
            name="Date_Value",
            datatype="GPDate",
            parameterType="Required",
            direction="Input")

        params = [param0, param1, param2]
        return params

    def isLicensed(self):
        """Set whether tool is licensed to execute."""
        return True

    def updateParameters(self, parameters):
        """Modify the values and properties of parameters before internal
        validation is performed.  This method is called whenever a parameter
        has been changed."""
        return

    def updateMessages(self, parameters):
        """Modify the messages created by internal validation for each tool
        parameter.  This method is called after internal validation."""
        return

    def execute(self, parameters, messages):
        try:
            """The source code of the tool."""
            Target_Metadata = parameters[0].valueAsText
            Date_Label = parameters[1].valueAsText
            Date_Value = parameters[2].valueAsText

            dateTypeLookup = {"Publication Date":"pubDate", "Creation Date":"createDate", "Revision Date":"reviseDate"}
            dateType = dateTypeLookup[Date_Label]
            dateXpath = "dataIdInfo/idCitation/date/" + dateType

            # Use the provided inputs to run editElement tool.
            editElem = editElement()
            editParams = editElem.getParameterInfo()
            this_Metadata = editParams[0]
            this_Metadata.value = Target_Metadata
            Xpath_Expression = editParams[1]
            Xpath_Expression.value = dateXpath
            New_Value = editParams[2]
            New_Value.value = Date_Value

            editElem.execute([this_Metadata,Xpath_Expression,New_Value],messages)

        except:
            # Cycle through Geoprocessing tool specific errors
            for msg in range(0, arcpy.GetMessageCount()):
                if arcpy.GetSeverity(msg) == 2:
                    arcpy.AddReturnMessage(msg)
        finally:
            # Regardless of errors, clean up intermediate products.
            pass
        return

class keywords2tags(object):
    def __init__(self):
        """Define the tool (tool name is the name of the class)."""
        self.label = "Copy Keywords to Tags"
        self.description = "This tool copies ALL keywords present in the metadata to the Tags section. The tool does not alter the keywords, and any existing 'tags' will be preserved but not duplicated. Note that 'tags' should be empty when creating compliant metadata, but this utility is useful prior to sharing as a web layer."
        self.canRunInBackground = False

    def getParameterInfo(self):
        """Define parameter definitions"""
        # Second parameter
        param0 = arcpy.Parameter(
            displayName="Target Metadata",
            name="Target_Metadata",
            datatype="DEType",
            parameterType="Required",
            direction="Input",
            multiValue=True)

        params = [param0]
        return params

    def isLicensed(self):
        """Set whether tool is licensed to execute."""
        return True

    def updateParameters(self, parameters):
        """Modify the values and properties of parameters before internal
        validation is performed.  This method is called whenever a parameter
        has been changed."""
        return

    def updateMessages(self, parameters):
        """Modify the messages created by internal validation for each tool
        parameter.  This method is called after internal validation."""
        return

    def execute(self, parameters, messages):
        # for keywords2tags
        def create_keyword(string_value):
            keyW = ET.TreeBuilder()
            keyW.start('keyword')
            keyW.data(string_value)
            keyW.end('keyword')
            keywordComponent = keyW.close()
            return keywordComponent

        # for keywords2tags
        def getPcode(pCode, Progroot):
            progcodes_xp = "ProgramCode/[pCode='{}']/programName".format(pCode)
            programcode = Progroot.find(progcodes_xp)
            pc = programcode.text
            return pc
        try:
            """The source code of the tool."""
            Metadata_Inputs = parameters[0].valueAsText
            # emeDB path
            emeDB_path = os.path.join(os.getenv('APPDATA'), 'U.S. EPA', 'EME Toolkit', 'EMEdb')
            messages.addMessage(emeDB_path)

            for t in str(Metadata_Inputs).split(";"):

                messages.addMessage("Copying keywords to tags for {}".format(t))

                emeDB_path = os.path.join(os.getenv('APPDATA'), 'U.S. EPA', 'EME Toolkit', 'EMEdb')
                messages.addMessage(emeDB_path)

                target_md = md.Metadata(t)
                messages.addMessage(target_md.title)
                target_root = ET.fromstring(target_md.xml)
                searchKeys_xp = "dataIdInfo/searchKeys"
                existingTags = [t.text for t in target_root.findall(searchKeys_xp + "/keyword")]
                messages.addMessage(existingTags)

                # ISO 19115-3 Topic Categories
                tpCat_lookup = {'001': 'Farming',
                                '002': 'Biota',
                                '003': 'Boundaries',
                                '004': 'Atmospheric Science',
                                '005': 'Economy',
                                '006': 'Elevation',
                                '007': 'Environment',
                                '008': 'Geoscientific',
                                '009': 'Health',
                                '010': 'Imagery & Basemaps',
                                '011': 'Military & Intelligence',
                                '012': 'Inland Waters',
                                '013': 'Location',
                                '014': 'Oceans',
                                '015': 'Planning & Cadastral',
                                '016': 'Society',
                                '017': 'Structure',
                                '018': 'Transportation',
                                '019': 'Utilities & Communication'}
                tpCat_xp = "dataIdInfo/tpCat/TopicCatCd[@value]"
                tpCat_values = [tpCat_lookup[x.attrib['value']] for x in target_root.findall(tpCat_xp)]
                tpCat_keywords = [create_keyword(kw) for kw in tpCat_values]

                # # EPA Keywords
                # epaKeywords_xp = "dataIdInfo/themeKeys/thesaName/[resTitle='EPA GIS Keyword Thesaurus'][1]/../keyword"
                # epaKeywords_keywords = [kw for kw in target_root.findall(epaKeywords_xp)]
                #
                # # Place Keywords
                # placeKeywords_xp = "dataIdInfo/placeKeys/thesaName/[resTitle='EPA Place Names'][1]/../keyword"
                # placeKeywords_keywords = [kw for kw in target_root.findall(placeKeywords_xp)]

                # Program Codes
                programCodes_path = os.path.join(emeDB_path, 'ProgramCode.xml')
                programCodes_root = ET.parse(programCodes_path).getroot()
                programCodes_xp = "dataIdInfo/themeKeys/thesaName/[resTitle='Federal Program Inventory'][1]/../keyword"
                programCodes_code_keyw = target_root.findall(programCodes_xp)

                programCodes_values = [getPcode(v.text, programCodes_root) for v in
                                       target_root.findall(programCodes_xp)]
                programCodes_keywords = [create_keyword(kw) for kw in programCodes_values]
                messages.addMessage(programCodes_values)

                # All keywords (includes user, epa, place, custom, and program code keywords
                gen_keywords_xp = './/keyword'
                gen_keywords_all = target_root.findall(gen_keywords_xp)
                gen_keywords = [x for x in gen_keywords_all if x not in programCodes_code_keyw]

                # Parent searchKeys component
                searchKeys_xp = "dataIdInfo/searchKeys"
                tags_parent_node = target_root.findall(searchKeys_xp)
                if not tags_parent_node:
                    messages.addMessage('Creating searchKeys component...')
                    # Then need to create searchKeys
                    dataIdInfo = target_root.find('dataIdInfo')
                    sK = ET.TreeBuilder()
                    sK.start('searchKeys')
                    sK.end('searchKeys')
                    md_component = sK.close()
                    dataIdInfo.append(deepcopy(md_component))
                tags_parent_node = target_root.find(searchKeys_xp)

                for keys in [tpCat_keywords, gen_keywords, programCodes_keywords]:
                    try:
                        for kw in keys:
                            if kw.text in existingTags:
                                print('{} already exists as Tag'.format(kw.text))
                                messages.addMessage('{} already exists as Tag'.format(kw.text))
                                continue
                            try:
                                tags_parent_node.append(deepcopy(kw))
                                existingTags.append(kw.text)
                                messages.addMessage('{} added to Tags'.format(kw.text))
                            except Exception as ee:
                                print(ee)
                                messages.addWarningMessage(ee)
                    except Exception as ee:
                        print(ee)
                        messages.addWarningMessage(ee)
                messages.addMessage("Process complete - please review the output carefully.")
                # Save
                target_md.xml = ET.tostring(target_root)
                try:
                    fileExtension = t[-4:].lower()
                    if fileExtension == ".xml":
                        try:
                            os.remove(target_md.uri)
                            target_md.saveAsXML(target_md.uri)
                        except Exception as ee:
                            messages.addWarningMessage(ee)
                    target_md.save()
                except Exception as ee:
                    print(ee)
                    messages.addWarningMessage(ee)
        except:
            # Cycle through Geoprocessing tool specific errors
            for msg in range(0, arcpy.GetMessageCount()):
                if arcpy.GetSeverity(msg) == 2:
                    arcpy.AddReturnMessage(msg)
        finally:
            # Regardless of errors, clean up intermediate products.
            pass
        return


