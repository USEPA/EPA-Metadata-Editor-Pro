import os
import re
import arcpy
from arcpy import metadata as md
import xml.etree.ElementTree as ET
import sys


class Toolbox(object):
    def __init__(self):
        """Define the toolbox (the name of the toolbox is the name of the
        .pyt file)."""
        self.label = "EPA Pro Metadata Toolbox"
        self.alias = ""

        # List of tool classes associated with this toolbox
        self.tools = [upgradeTool,saveTemplate,importTool,deleteTool,cleanExportTool,editElement,editDates, copyFromTemplate, exportISOTool]
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
                # todo - need to check for ArcGISFormat 1.0 as well (mdStanName might be a legacy ISO element)
                root = ET.fromstring(source_md.xml)

                # if no ArcGIS Elements - metadata has not been upgraded yet
                if not any((root.findall('Esri/ArcGISFormat'), root.findall('mdStanName'))):
                    messages.addMessage("Upgrading the metadata for {}".format(t))
                    # Process: Upgrade Metadata
                    source_md.upgrade('FGDC_CSDGM')

                    messages.addMessage("Cleaning up legacy elements and preserving the UUID...")
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

class copyFromTemplate(object):
    def __init__(self):
        """Define the tool (tool name is the name of the class)."""
        self.label = "Merge a selected metadata record with a saved template"
        self.description = "This tool merges a selected metadata record with elements from a saved template record. Elements from the template record will overwrite their equivalents in the selected record, but by design it will exclude those elements which must be unique in every metadata record, such as title, abstract, unique identifier, etc, replacing only those elements that are common across many records. Still, caution is urged when using this tool."
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

        param2 = arcpy.Parameter(
            displayName="Update Elements",
            name="Xpath_Expression",
            datatype="GPString",
            parameterType="Optional",
            direction="Input",
            multiValue=True
        )
        param2.value = ["dataIdInfo/idCitation/resTitle","dataIdInfo/idAbs","dataIdInfo/idPurp"]
        # param2.value = ["mdLang/languageCode"]

        params = [param0, param1, param2]
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

        messages.addMessage("Setting Defaults...")
        # tool_file_path = os.path.dirname(os.path.realpath(__file__))
        from copy import deepcopy

        try:
            """The source code of the tool."""
            Template_Metadata = parameters[1].valueAsText
            template_md = md.Metadata(Template_Metadata)
            Target_Metadata = parameters[0].valueAsText

            xpath_list = parameters[2].valueAsText

            for t in str(Target_Metadata).split(';'):
                if ' ' in t:
                    messages.addWarningMessage('*Merge process skipped for {} due to space found in name'.format(t))
                    continue

                source_md = md.Metadata(t)
                source_root = ET.fromstring(source_md.xml)
                template_root = ET.fromstring(template_md.xml)

                for xp in str(xpath_list).split(';'):
                    messages.addMessage(xp)
                    if len(template_root.findall(xp)) > 0:
                        messages.addMessage('found in template {}'.format(xp))
                        # Remove source data
                        if len(source_root.findall(xp)) > 0:
                            parent = source_root
                            parent_list = []
                            node_split = xp.split("/")
                            for n in node_split[:-1]:
                                parent_list.append(n)
                                parent_xpath = '/'.join(parent_list)
                                parent = source_root.findall(parent_xpath)[0]
                            messages.addMessage('removing source node')
                            try:
                                for e in source_root.findall(xp):
                                    messages.addMessage('find node')
                                    parent.remove(e)
                                    messages.addMessage('node removed')
                            except Exception as ee:
                                messages.addMessage(ee)
                        # Add template data into source
                        # This section iterates through the xpath components, adding any missing SubElements so there's at least one element to populate.
                        xpathElements = xp.split("/")
                        xpathList = []
                        thisNode = source_root
                        for xpathElem in xpathElements[:-1]:
                            xpathList.append(xpathElem)
                            buildXPath = "/".join(xpathList)
                            if len(source_root.findall(buildXPath)) == 0:
                                ET.SubElement(thisNode, xpathElem)
                            thisNode = source_root.findall(buildXPath)[0]

                        for template_element in template_root.findall(xp):
                            try:
                                thisNode.append(deepcopy(template_element))
                                messages.addMessage('nodes copied back in')
                            except Exception as ee:
                                messages.addMessage(ee)

                messages.addMessage('saving xml string back to md')
                source_md.xml = ET.tostring(source_root)
                messages.addMessage('saving string worked')
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
                    messages.addMessage("Process complete - please review the output carefully before importing or harvesting.")
                    messages.addMessage("Output: {}".format(t))

                else:
                    messages.addWarningMessage("Error processing {}.".format(t))

                # can't save directly if xml and no need to sync

                # source_md.save()
                # messages.addMessage('Copied Template')
                # # Only run this if a featureclass, skip for xml
                # # source_md.synchronize(metadata_sync_option='SELECTIVE')
                # messages.addMessage('Syncd')
                # source_md.synchronize(metadata_sync_option='OVERWRITE')
                #
                # source_root = ET.fromstring(source_md.xml)
                # source_copy_root = ET.fromstring(source_copy_md.xml)
                # messages.addMessage('xml copied to ET')
                # source_md.summary = source_copy_md.summary
                # source_md.title = source_copy_md.title
                # source_md.description = source_copy_md.description

                # for xp in str(xpath_list).split(';'):
                #     messages.addMessage(xp)
                #     try:
                #         for e in source_root.findall(xp):
                #             messages.addMessage('find node')
                #             source_root.remove(e)
                #             messages.addMessage('nodes removed')
                #             messages.addMessage(e)
                #     except Exception as ee:
                #         messages.addMessage(ee)
                #     try:
                #         for e in source_copy_root.findall(xp):
                #             source_root.append(deepcopy(e))
                #             messages.addMessage('nodes copied back in')
                #     except Exception as ee:
                #         messages.addMessage(ee)

                # source_md.xml = ET.tostring(source_root)
                # messages.addMessage('XML from ET back to MD')
                # source_md.saveAsXML(Output_Metadata)
                # messages.addMessage('save as xml to {}'.format(Output_Metadata))

                # output_md = md.Metadata(Source_Metadata)
                # template_nm = '_{}.xml'.format(re.sub('[^_0-9a-zA-Z]+', '', os.path.splitext(os.path.basename(template_md.uri))[0]))
                # source_nm = '_{}.xml'.format(re.sub('[^_0-9a-zA-Z]+', '', os.path.splitext(os.path.basename(source_md.uri))[0]))

                # try:
                    # Template md should be processed through the save as template to be safe,
                    # process the result of save as template

                    # saveTemplate_xslt = tool_file_path + r"\saveTemplate.xslt"
                    # template_md.saveAsUsingCustomXSLT(os.path.join(scratch_folder, template_nm), saveTemplate_xslt)
                    # source_md.saveAsUsingCustomXSLT(os.path.join(scratch_folder, source_nm), saveTemplate_xslt)
                    # clean_template_md = md.Metadata(os.path.join(scratch_folder, template_nm))
                    # thinking we can run the save template on the source and then return the
                    # list of elements in og_source not in clean_source. Those will be the elements
                    # we want to bring into the template.
                    # clean_source_md = md.Metadata(os.path.join(scratch_folder, source_nm))

                    # source_root = ET.fromstring(source_md.xml)
                    # clean_source_root = ET.fromstring(clean_source_md.xml)
                    # s = ''
                    # sc = ''
                    # for e in source_root.getchildren():
                    #     s = '{}{}{}'.format(s, ' | ', e.tag)
                    #
                    # for e in clean_source_root.getchildren():
                    #     sc = '{}{}{}'.format(sc, ' | ', e.tag)
                    #
                    # messages.addMessage(s)
                    # messages.addMessage(sc)

                    # output_md.copy(source_md)
                    # messages.addMessage("Output md Title "+ str(output_md.title))
                    # output_md.importMetadata(template_md, metadata_import_option='CUSTOM', customStylesheetPath=mergeTemplate_xslt)
                    # output_md.saveAsXML(outputPath=Output_Metadata)
                # except Exception as e:
                #     messages.addWarningMessage(e)

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


class mergeTemplate(object):
    def __init__(self):
        """Define the tool (tool name is the name of the class)."""
        self.label = "Merge a selected metadata record with a saved template"
        self.description = "This tool merges a selected metadata record with elements from a saved template record. Elements from the template record will overwrite their equivalents in the selected record, but by design it will exclude those elements which must be unique in every metadata record, such as title, abstract, unique identifier, etc, replacing only those elements that are common across many records. Still, caution is urged when using this tool."
        self.canRunInBackground = False

    def getParameterInfo(self):
        """Define parameter definitions"""

        param0 = arcpy.Parameter(
            displayName="Template Metadata",
            name="Template_Metadata",
            datatype="DEFile",
            parameterType="Required",
            direction="Input")

        param1 = arcpy.Parameter(
            displayName="Target Metadata",
            name="Target_Metadata",
            datatype="DEType",
            parameterType="Required",
            direction="Input",
            multiValue=True)

        param2 = arcpy.Parameter(
            displayName="Overwrite Source Record",
            name="Overwrite",
            datatype="GPBoolean",
            parameterType="Required",
            direction="Input"
        )
        param2.value = "True"

        param3 = arcpy.Parameter(
            displayName="Output Directory",
            name="Output_Metadata",
            datatype="DEFolder",
            parameterType="Optional",
            direction="Input")

        param4 = arcpy.Parameter(
            displayName="File Prefix",
            name="FilePrefix",
            datatype="GPString",
            parameterType="Optional",
            direction="Input"
        )
        param4.value = "merge_"

        param5 = arcpy.Parameter(
            displayName="Preserve Source Element",
            name="Xpath_Expression",
            datatype="GPString",
            parameterType="Optional",
            direction="Input",
            multiValue=True
        )
        param5.value = ["dataIdInfo/idCitation/resTitle","dataIdInfo/idAbs","dataIdInfo/idPurp"]

        params = [param0, param1, param2, param3, param4, param5]
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

        if parameters[2].value is True:
            parameters[3].enabled = 'False'
            parameters[4].enabled = 'False'
        else:
            parameters[3].enabled = 'True'
            parameters[4].enabled = 'True'


        return

    def updateMessages(self, parameters):
        """Modify the messages created by internal validation for each tool
        parameter.  This method is called after internal validation."""

        if parameters[2].value is False and parameters[3].value is None:
            parameters[3].setErrorMessage("Folder Required")

        if parameters[2].value is False and parameters[4].value is None:
            parameters[4].setErrorMessage("File Prefix Required")

        return

    def execute(self, parameters, messages):

        messages.addMessage("Merging...")
        # tool_file_path = os.path.dirname(os.path.realpath(__file__))
        from copy import deepcopy

        try:
            """The source code of the tool."""
            Template_Metadata = parameters[0].valueAsText
            template_md = md.Metadata(Template_Metadata)
            Target_Metadata = parameters[1].valueAsText
            overwrite_md = parameters[2].valueAsText

            scratch_folder = arcpy.env.scratchFolder
            output_dir = parameters[3].valueAsText
            output_prefix = parameters[4].valueAsText
            if not output_prefix:
                output_prefix = 'tmp_'
            if not output_dir:
                output_dir = arcpy.env.scratchFolder

            xpath_list = parameters[5].valueAsText

            #ToDo: Start Loop here for multiple source MDs
            for t in str(Target_Metadata).split(';'):
                if ' ' in t:
                    messages.addWarningMessage('*Merge process skipped for {} due to space found in name'.format(t))
                    continue

                basename = re.sub('[^_0-9a-zA-Z]+', '', os.path.splitext(os.path.basename(t))[0])

                output_name = "{}{}.xml".format(output_prefix, basename)
                output_metadata = ""
                # messages.addMessage(t)

                # Set source so we have the URI, then can copy from template
                source_md = md.Metadata(t)
                source_copy_md = md.Metadata(t)
                source_md.copy(template_md)


                try:
                    if overwrite_md == 'true':
                        # if overwriting and FC then save>sync>preserve elements>save.
                        fileExtension = t[-4:].lower()
                        if fileExtension == ".xml":
                            try:
                                os.remove(source_md.uri)
                            except Exception as ee:
                                messages.addWarningMessage(ee)

                            source_md.summary = source_copy_md.summary
                            source_md.title = source_copy_md.title
                            source_md.description = source_copy_md.description
                            # Need to save UUID also, but this will be xpath
                            source_md.saveAsXML(source_md.uri)
                        else:
                            # for feature classes, we have to save, sync, bring back the preserved
                            # elements and then save again
                            source_md.save()
                            source_md.reload()
                            source_md.summary = source_copy_md.summary
                            source_md.title = source_copy_md.title
                            source_md.description = source_copy_md.description
                            # Need to save UUID also, but this will be xpath
                            source_md.save()

                        output_metadata = source_md.uri

                    else:

                        final_xml = os.path.join(output_dir, output_name)
                        output_metadata = final_xml
                        source_md.summary = source_copy_md.summary
                        source_md.title = source_copy_md.title
                        source_md.description = source_copy_md.description
                        # Need to save UUID also, but this will be xpath
                        source_md.saveAsXML(final_xml)


                except Exception as e:
                    messages.addMessage(e)

                if arcpy.Exists(output_metadata):
                    messages.addMessage("Process complete - please review the output carefully before importing or harvesting.")
                    messages.addMessage("Output: {}".format(output_metadata))

                else:
                    messages.addWarningMessage("Error processing {}.".format(t))

                # can't save directly if xml and no need to sync

                # source_md.save()
                # messages.addMessage('Copied Template')
                # # Only run this if a featureclass, skip for xml
                # # source_md.synchronize(metadata_sync_option='SELECTIVE')
                # messages.addMessage('Syncd')
                # source_md.synchronize(metadata_sync_option='OVERWRITE')
                #
                # source_root = ET.fromstring(source_md.xml)
                # source_copy_root = ET.fromstring(source_copy_md.xml)
                # messages.addMessage('xml copied to ET')
                # source_md.summary = source_copy_md.summary
                # source_md.title = source_copy_md.title
                # source_md.description = source_copy_md.description

                # for xp in str(xpath_list).split(';'):
                #     messages.addMessage(xp)
                #     try:
                #         for e in source_root.findall(xp):
                #             messages.addMessage('find node')
                #             source_root.remove(e)
                #             messages.addMessage('nodes removed')
                #             messages.addMessage(e)
                #     except Exception as ee:
                #         messages.addMessage(ee)
                #     try:
                #         for e in source_copy_root.findall(xp):
                #             source_root.append(deepcopy(e))
                #             messages.addMessage('nodes copied back in')
                #     except Exception as ee:
                #         messages.addMessage(ee)

                # source_md.xml = ET.tostring(source_root)
                # messages.addMessage('XML from ET back to MD')
                # source_md.saveAsXML(Output_Metadata)
                # messages.addMessage('save as xml to {}'.format(Output_Metadata))

                # output_md = md.Metadata(Source_Metadata)
                # template_nm = '_{}.xml'.format(re.sub('[^_0-9a-zA-Z]+', '', os.path.splitext(os.path.basename(template_md.uri))[0]))
                # source_nm = '_{}.xml'.format(re.sub('[^_0-9a-zA-Z]+', '', os.path.splitext(os.path.basename(source_md.uri))[0]))

                # try:
                    # Template md should be processed through the save as template to be safe,
                    # process the result of save as template

                    # saveTemplate_xslt = tool_file_path + r"\saveTemplate.xslt"
                    # template_md.saveAsUsingCustomXSLT(os.path.join(scratch_folder, template_nm), saveTemplate_xslt)
                    # source_md.saveAsUsingCustomXSLT(os.path.join(scratch_folder, source_nm), saveTemplate_xslt)
                    # clean_template_md = md.Metadata(os.path.join(scratch_folder, template_nm))
                    # thinking we can run the save template on the source and then return the
                    # list of elements in og_source not in clean_source. Those will be the elements
                    # we want to bring into the template.
                    # clean_source_md = md.Metadata(os.path.join(scratch_folder, source_nm))

                    # source_root = ET.fromstring(source_md.xml)
                    # clean_source_root = ET.fromstring(clean_source_md.xml)
                    # s = ''
                    # sc = ''
                    # for e in source_root.getchildren():
                    #     s = '{}{}{}'.format(s, ' | ', e.tag)
                    #
                    # for e in clean_source_root.getchildren():
                    #     sc = '{}{}{}'.format(sc, ' | ', e.tag)
                    #
                    # messages.addMessage(s)
                    # messages.addMessage(sc)

                    # output_md.copy(source_md)
                    # messages.addMessage("Output md Title "+ str(output_md.title))
                    # output_md.importMetadata(template_md, metadata_import_option='CUSTOM', customStylesheetPath=mergeTemplate_xslt)
                    # output_md.saveAsXML(outputPath=Output_Metadata)
                # except Exception as e:
                #     messages.addWarningMessage(e)

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
