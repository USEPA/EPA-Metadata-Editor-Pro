import arcpy
from arcpy import metadata as md


try:
    """The source code of the tool."""
    Target_Metadata = arcpy.GetParameter(0)

    # Local variables:
    blankDoc = "blankdoc.xml"
    src_md = md.Metadata(blankDoc)

    for f in Target_Metadata:

        arcpy.AddMessage("Performing complete purge of existing metadata")
        # Process: Purge
        # arcpy.MetadataImporter_conversion(blankDoc, Target_Metadata)
        target_md = md.Metadata(f)

        if not target_md.isReadOnly:
            target_md.copy(src_md)
            target_md.save()
            # arcpy.AddMessage("Importing new metadata")
            arcpy.AddMessage("Process complete - please review the output carefully.")
        else:
            arcpy.AddMessage("Unable to save. Metadata Is Read Only.")
except:
    # Cycle through Geoprocessing tool specific errors
    for msg in range(0, arcpy.GetMessageCount()):
        if arcpy.GetSeverity(msg) == 2:
            arcpy.AddReturnMessage(msg)
finally:
    # Regardless of errors, clean up intermediate products.
    pass

