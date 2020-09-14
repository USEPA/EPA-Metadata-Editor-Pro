import os

import arcpy
from arcpy import metadata as md
import sys


class Toolbox(object):
    def __init__(self):
        """Define the toolbox (the name of the toolbox is the name of the
        .pyt file)."""
        self.label = "EPA Pro Metadata Toolbox"
        self.alias = ""

        # List of tool classes associated with this toolbox
        self.tools = [upgradeTool,cleanupTool,saveTemplate,importTool,deleteTool,cleanExportTool,editElement,editDates,mergeTemplate, exportISOTool]
        # self.tools = [upgradeTool,cleanupTool,exportISOTool,saveTemplate,importTool,deleteTool,cleanExportTool,editElement,editDates, mergeTemplate]

# class scratchCopy(object):
#     def __init__(self,messages):
#         self.messages = messages
#         self.scratchXML = ""
#
#     def makeScratchCopy(self, Source_Metadata):
#
#         # Esri-provided standard stylesheet for copying metadata.
#
#         tool_file_path = os.path.dirname(os.path.realpath(__file__))
#         EPACleanExport_xslt = tool_file_path + r"\EPACleanExport.xslt"
#
#         # exact_copy_of_xslt = arcpy.GetInstallInfo()['InstallDir'] + "Metadata\\Stylesheets\\gpTools\exact Copy Of.xslt"
#         self.scratchWorkspace = arcpy.env.scratchFolder
#         self.scratchXML = arcpy.CreateScratchName(suffix=".xml", workspace=self.scratchWorkspace)
#
#
#         self.messages.addMessage("Making a temporary copy of the existing metadata...")
#         # Process: Copy Metadata for Upgrade
#         arcpy.XSLTransform_conversion(Source_Metadata, exact_copy_of_xslt, self.scratchXML, "")
#         return self.scratchXML
#
#     def cleanupScratchCopy(self):
#         self.messages.addMessage("Cleaning up scratch files...")
#         if arcpy.Exists(self.scratchXML):
#             arcpy.Delete_management(self.scratchXML)

class upgradeTool(object):
    def __init__(self):
        """Define the tool (tool name is the name of the class)."""
        self.label = "EPA Upgrade FGDC to ArcGIS"
        self.description = "This tool creates a copy of the existing FGDC CSDGM metadata, performs the standard upgrade to ArcGIS Metadata, then adds several extra cleanup steps including copying legacy UUIDs to the ISO-Compliant element and cleaning up all legacy elements. This tool is not recommended for records that have already been upgraded to ArcGIS Metadata."
        self.canRunInBackground = False

    def getParameterInfo(self):
        """Define parameter definitions"""
            # first parameter
        # param0 = arcpy.Parameter(
        #     displayName="Source Metadata",
        #     name="Source_Metadata",
        #     datatype="DEType",
        #     parameterType="Required",
        #     direction="Input")
        param0 = arcpy.Parameter(
            displayName="Source Metadata",
            name="Source_Metadata",
            datatype="DEType",
            parameterType="Required",
            direction="Input",
            multiValue=True)

        # output metadata parameter
        # param1 = arcpy.Parameter(
        #     displayName="Output Metadata",
        #     name="Output_Metadata",
        #     datatype="DEFile",
        #     parameterType="Required",
        #     direction="Output")

        param1 = arcpy.Parameter(
            displayName="Output Directory",
            name="Output_Metadata",
            datatype="DEFolder",
            parameterType="Required",
            direction="Output")

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
        Target_Metadata = parameters[0].valueAsText
        try:
            for t in str(Target_Metadata).split(";"):

                target_md = md.Metadata(t)
            # TODO: Need to check the current metadata format? Pro's tool will check and not allow
            # an upgrade depending on the format detected.
            """The source code of the tool."""
            # Source_Metadata = parameters[0].valueAsText
            Output_Name = "_{}_upgrade.xml".format(os.path.basename(t))
            Output_Dir = parameters[1].valueAsText
            Output_Metadata = os.path.join(Output_Dir, Output_Name)
            messages.addMessage(Output_Metadata)


            source_md = md.Metadata(t)
            output_md = md.Metadata()
            output_md.copy(source_md)

            # Use scratchCopy class to make a standalone XML doc to work with.
            # scratchCopier = scratchCopy(messages)
            # Copy_to_be_upgraded = scratchCopier.makeScratchCopy(Source_Metadata)

            messages.addMessage("Upgrading the metadata...")
            # Process: Upgrade Metadata
            output_md.upgrade('FGDC_CSDGM')
            # Upgraded_Metadata = arcpy.UpgradeMetadata_conversion(Copy_to_be_upgraded, "FGDC_TO_ARCGIS")

            tool_file_path = os.path.dirname(os.path.realpath(__file__))
            EPAUpgradeCleanup_xslt = tool_file_path + r'\EPAUpgradeCleanup.xslt'

            messages.addMessage("Preserving the UUID and cleaning up legacy elements...")
            try:
                output_md.saveAsUsingCustomXSLT(Output_Metadata, EPAUpgradeCleanup_xslt)
                # Process: EPA Cleanup
                # arcpy.XSLTransform_conversion(Upgraded_Metadata, EPAUpgradeCleanup_xslt, Output_Metadata, "")
            except Exception as e:
                messages.addMessage(e)

            if arcpy.Exists(Output_Metadata):
                messages.addMessage("Process complete - please review the output carefully before importing or harvesting.")

            else:
                messages.addMessage("Error Creating file.")

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
            direction="Output")

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
                Output_Name = "_{}_cleanup.".format(os.path.basename(t))
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
                    messages.addMessage(e)

                if arcpy.Exists(Output_Metadata):
                    messages.addMessage("Process complete - please review the output carefully before importing or harvesting.")

                else:
                    messages.addMessage("Error Creating file.")

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
            messages.addMessage(Target_Metadata)
            Output_Dir = parameters[1].valueAsText
            ISO_format = parameters[2].valueAsText

            for t in str(Target_Metadata).split(";"):
                Output_Name = "_{0}_{1}.xml".format(os.path.basename(t), ISO_format)
                Output_Metadata = os.path.join(Output_Dir, Output_Name)
                messages.addMessage(t)
                messages.addMessage(Output_Metadata)
                messages.addMessage(ISO_format)

                # Local variables:
                messages.addMessage('Install Dir: {}'.format(arcpy.GetInstallInfo()['InstallDir']))
                # translator = arcpy.GetInstallInfo()['InstallDir'] + "Metadata\\Translator\\ArcGIS2ISO19139.xml"

                src_md = md.Metadata(t)
                # generate output path from input name
                src_md.exportMetadata(outputPath=Output_Metadata, metadata_export_option=ISO_format)

                if arcpy.Exists(Output_Metadata):
                    messages.addMessage("Process complete - please review the output carefully before importing or harvesting.")
                else:
                    messages.addMessage("Error Creating output.")

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
            direction="Input")

        param1 = arcpy.Parameter(
            displayName="Output Metadata",
            name="Output_Metadata",
            datatype="DEFile",
            parameterType="Required",
            direction="Output")

        params = [param0, param1]
        return params

    def isLicensed(self):
        """Set whether tool is licensed to execute."""
        return True

    def updateParameters(self, parameters):
        """Modify the values and properties of parameters before internal
        validation is performed.  This method is called whenever a parameter
        has been changed."""
        if parameters[1].valueAsText:
            fileExtension = parameters[1].valueAsText[-4:].lower()
            if fileExtension != ".xml":
                parameters[1].value = parameters[1].valueAsText + ".xml"
        return

    def updateMessages(self, parameters):
        """Modify the messages created by internal validation for each tool
        parameter.  This method is called after internal validation."""
        return

    def execute(self, parameters, messages):
        try:
            """The source code of the tool."""
            tool_file_path = os.path.dirname(os.path.realpath(__file__))

            Source_Metadata = parameters[0].valueAsText
            messages.addMessage(f'param 0 {Source_Metadata}')

            Output_Metadata = parameters[1].valueAsText
            messages.addMessage(f'param 1 {Output_Metadata}')

            source_md = md.Metadata(Source_Metadata)

            # Local variables:
            saveTemplate_xslt = tool_file_path + r"\saveTemplate.xslt"

            # Process: EPA Cleanup
            try:
                # arcpy.XSLTransform_conversion(Source_Metadata, saveTemplate_xslt, Output_Metadata, "")
                source_md.saveAsUsingCustomXSLT(Output_Metadata, saveTemplate_xslt)
            except Exception as e:
                messages.addMessage(e)

            if arcpy.Exists(Output_Metadata):
                messages.addMessage("Process complete - please review the output carefully before reusing as a template.")
            else:
                messages.addMessage("Error Creating file.")

        except:
            # Cycle through Geoprocessing tool specific errors
            for msg in range(0, arcpy.GetMessageCount()):
                if arcpy.GetSeverity(msg) == 2:
                    arcpy.AddReturnMessage(msg)
        finally:
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
            displayName="Source Metadata",
            name="Source_Metadata",
            datatype="DEType",
            parameterType="Required",
            direction="Input")

        param1 = arcpy.Parameter(
            displayName="Template Metadata",
            name="Template_Metadata",
            datatype="DEFile",
            parameterType="Required",
            direction="Input")

        param2 = arcpy.Parameter(
            displayName="Output Metadata",
            name="Output_Metadata",
            datatype="DEFile",
            parameterType="Required",
            direction="Output")

        params = [param0, param1, param2]
        return params

    def isLicensed(self):
        """Set whether tool is licensed to execute."""
        return True

    def updateParameters(self, parameters):
        """Modify the values and properties of parameters before internal
        validation is performed.  This method is called whenever a parameter
        has been changed."""
        if parameters[2].valueAsText:
            fileExtension = parameters[2].valueAsText[-4:].lower()
            if fileExtension != ".xml":
                parameters[2].value = parameters[2].valueAsText + ".xml"
        return

    def updateMessages(self, parameters):
        """Modify the messages created by internal validation for each tool
        parameter.  This method is called after internal validation."""
        return

    def execute(self, parameters, messages):
        messages.addMessage("Merging...")
        tool_file_path = os.path.dirname(os.path.realpath(__file__))
        messages.addMessage('file path ' + tool_file_path)

        try:
            """The source code of the tool."""

            tool_file_path = os.path.dirname(os.path.realpath(__file__))

            Source_Metadata = parameters[0].valueAsText
            Template_Metadata = parameters[1].valueAsText
            Output_Metadata = parameters[2].valueAsText

            source_md = md.Metadata(Source_Metadata)
            template_md = md.Metadata(Template_Metadata)
            source_md.saveAsXML(outputPath=Output_Metadata)
            output_md = md.Metadata(Output_Metadata)

            # TODO:  Find equivalent xslt transform that takes an input


            # Local variables:
            mergeTemplate_xslt = tool_file_path + r"\mergeTemplate.xslt"
            messages.addMessage('merge template path '+ mergeTemplate_xslt)

            if not arcpy.Exists(mergeTemplate_xslt):
                messages.addMessage(
                    "Merge Template does not exist.")
                raise Exception('merge template does not exist')

            # Process: EPA Cleanup
            # Source_Metadata
            # arcpy.XSLTransform_conversion(Source_Metadata, mergeTemplate_xslt, Output_Metadata, Template_Metadata)

            # Source_Metadata.saveAsUsingCustomXSLT(Output_Metadata, mergeTemplate_xslt, )
            try:

                output_md.copy(template_md)
                messages.addMessage("Output md Title "+ str(output_md.title))
                output_md.importMetadata(template_md, metadata_import_option='CUSTOM', customStylesheetPath=mergeTemplate_xslt)
                output_md.saveAsXML(outputPath=Output_Metadata)
            except Exception as e:
                messages.addMessage(e)

            if arcpy.Exists(Output_Metadata):
                messages.addMessage(
                    "Process complete - please review the output carefully before importing or harvesting.")

            else:
                messages.addMessage("Error Creating file.")

            messages.addMessage("Process complete - please review the output carefully.")
        except:
            # Cycle through Geoprocessing tool specific errors
            for msg in range(0, arcpy.GetMessageCount()):
                if arcpy.GetSeverity(msg) == 2:
                    arcpy.AddReturnMessage(msg)
        finally:
            messages.addMessage("Finally.")
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
            messages.addMessage("Target {}".format(Target_Metadata))
            # messages.addMessage("Parameter {}".format(parameters[0].value))

            # Local variables:
            blankDoc = "blankdoc.xml"
            source_md = md.Metadata(blankDoc)
            # messages.addMessage("Got the blank")

            for t in str(Target_Metadata).split(";"):

                messages.addMessage("Performing complete purge of existing metadata")
                # Process: Purge
                # arcpy.MetadataImporter_conversion(blankDoc, Target_Metadata)
                target_md = md.Metadata(t)

                if not target_md.isReadOnly:
                    # messages.addMessage(target_md.isReadOnly)
                    target_md.copy(source_md)
                    target_md.save()
                # arcpy.AddMessage("Importing new metadata")
                    messages.addMessage("Process complete - please review the output carefully.")
                else:
                    messages.addMessage("Unable to save. Metadata Is Read Only.")

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

            for t in str(Target_Metadata).split(";"):

                target_md = md.Metadata(t)

                if not target_md.isReadOnly:

                    # Process: Purge
                    # messages.addMessage("Performing complete purge of existing metadata")
                    # arcpy.MetadataImporter_conversion(blankDoc, Target_Metadata)

                    messages.addMessage("Importing new metadata")
                    # Process: Import
                    target_md.copy(source_md)
                    target_md.save()

                    # TODO: Should probably sync if it is a feature class. Need to check if FC
                    # target_md.synchronize('SELECTIVE')

                    # arcpy.MetadataImporter_conversion(Source_Metadata, Target_Metadata)

                    messages.addMessage("Process complete - please review the output carefully.")
                else:
                    messages.addMessage("Unable to save. Metadata Is Read Only.")

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
            # Second parameter
        param0 = arcpy.Parameter(
            displayName="Source Metadata",
            name="Source_Metadata",
            datatype="DEType",
            parameterType="Required",
            direction="Input")

        # Third parameter
        param1 = arcpy.Parameter(
            displayName="Output Metadata",
            name="Output_Metadata",
            datatype="DEFile",
            parameterType="Required",
            direction="Output")

        params = [param0, param1]
        return params

    def isLicensed(self):
        """Set whether tool is licensed to execute."""
        return True

    def updateParameters(self, parameters):
        """Modify the values and properties of parameters before internal
        validation is performed.  This method is called whenever a parameter
        has been changed."""
        if parameters[1].valueAsText:
            fileExtension = parameters[1].valueAsText[-4:].lower()
            if fileExtension != ".xml":
                parameters[1].value = parameters[1].valueAsText + ".xml"
        return

    def updateMessages(self, parameters):
        """Modify the messages created by internal validation for each tool
        parameter.  This method is called after internal validation."""
        return

    def execute(self, parameters, messages):
        try:
            """The source code of the tool."""

            tool_file_path = os.path.dirname(os.path.realpath(__file__))

            Source_Metadata = parameters[0].valueAsText
            Output_Metadata = parameters[1].valueAsText

            source_md = md.Metadata(Source_Metadata)

            # Local variables:
            EPACleanExport_xslt = tool_file_path + r"\EPACleanExport.xslt"

            messages.addMessage("Exporting the metadata record...")
            # Process: EPA Cleanup
            try:
                source_md.saveAsUsingCustomXSLT(Output_Metadata, EPACleanExport_xslt)
            except Exception as e:
                messages.addMessage(e)
            # # arcpy.XSLTransform_conversion(Source_Metadata, EPACleanExport_xslt, Output_Metadata, "")

            if arcpy.Exists(Output_Metadata):
                messages.addMessage("Process complete - please review the output carefully before importing or harvesting.")

            else:
                messages.addMessage("Error Creating file.")

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
                import xml.etree.ElementTree as ET
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
                messages.addMessage("writing back to xml object")

                if not target_md.isReadOnly:
                    target_md.xml = ET.tostring(root)
                    target_md.save()
                    messages.addMessage("Process complete, element update count: {}.".format(str(len(elements))))
                else:
                    messages.addMessage("Unable to save. Metadata Is Read Only.")

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
        self.label = "EPA Edit Metadata Dates Tool"
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
