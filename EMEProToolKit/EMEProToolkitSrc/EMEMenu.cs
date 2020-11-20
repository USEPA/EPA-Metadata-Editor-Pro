using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Input;
using ArcGIS.Core.CIM;
using ArcGIS.Core.Data;
using ArcGIS.Core.Geometry;
using ArcGIS.Desktop.Catalog;
using ArcGIS.Desktop.Core;
using ArcGIS.Desktop.Editing;
using ArcGIS.Desktop.Extensions;
using ArcGIS.Desktop.Framework;
using ArcGIS.Desktop.Framework.Contracts;
using ArcGIS.Desktop.Framework.Dialogs;
using ArcGIS.Desktop.Framework.Threading.Tasks;
using ArcGIS.Desktop;
using ArcGIS.Desktop.Mapping;
using ArcGIS.Desktop.Core.Geoprocessing;
using ArcGIS.Desktop.Layouts;
using System.Xml;
using ActiproSoftware.Windows.Controls;
using System.IO;
using System.Diagnostics;
using System.Windows.Controls.Primitives;

namespace EMEProToolkit
{
    
    public class EMEMenu_UpdateContacts : ArcGIS.Desktop.Framework.Contracts.Button
    {
        protected override async void OnClick()
        {
            //TODO: Create/reference Async Process for updating contacts
            var AsyncContacts = new AsyncContacts();
            await AsyncContacts.LoadContactsAsync(checksyncage:false);
        }
    }
    internal class EMEMenu_test : Button
    {
        protected override void OnClick()
        {
            QueuedTask.Run(() =>
            {
                var newMap = MapFactory.Instance.CreateMap("junk", basemap: Basemap.ProjectDefault);
                //TODO: use the map...
                //ProApp.Panes.CreateMapPaneAsync(newMap);

                //MapView

                //string s = MapView.Active.Map.Name;
                //MessageBox.Show(s);

                //Map j = MapView.Active.Map;

            });

            //string s = MapView.Active.Map.Name;
            //MessageBox.Show(s);


            //Map newMap = MapFactory.Instance.CreateMap("junk", MapType.Map, MapViewingMode.Map, Basemap.Streets);
            //string url = @"http://sampleserver1.arcgisonline.com/ArcGIS/rest/services/Demographics/ESRI_Census_USA/MapServer";
            //Uri uri = new Uri(url);
            //LayerFactory.Instance.CreateLayer(uri, newMap);



            //Coordinate2D ll = new Coordinate2D(1, 0.5);
            //Coordinate2D ur = new Coordinate2D(13, 9);
            //Envelope mapEnv = EnvelopeBuilder.CreateEnvelope(ll, ur);

            //MessageBox.Show(newMap.Name.ToString());


        }
    }
        
    //internal class EMEMenu_UpdateThumbnail : Button
    //{
    //    protected override async void OnClick()
    //    {
    //        var thumbsup = new ThumbnailUpdater();
    //        thumbsup.ExportFrameAsync();



    //    }
    //}

    internal class EMEMenu_clearMD : Button
    {
        private string _pathEmeToolbox = System.Environment.GetFolderPath(System.Environment.SpecialFolder.ApplicationData) + "\\U.S. EPA\\EME Toolkit\\EMEProToolBox\\";
        //private string _installPath = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);
        
        protected override void OnClick()
        {            
            try
            {

                //MessageBox.Show(Path.GetTempPath());
                //MessageBox.Show(_installPath);
                string j = "";
                var arguments = Geoprocessing.MakeValueArray(j);
                string toolpath = _pathEmeToolbox + "\\EPA Pro Metadata Toolbox.pyt\\deleteTool";
                Geoprocessing.OpenToolDialog(toolpath, null);

                #region  Exmample for calling python

                //// Inform user that add-in is about to call Python script.
                //ArcGIS.Desktop.Framework.Dialogs.MessageBox.Show("Click OK to start script, and wait for completion messagebox.", "Info");
                //// Create and format path to Pro
                //var pathProExe = System.IO.Path.GetDirectoryName((new System.Uri(Assembly.GetEntryAssembly().CodeBase)).AbsolutePath);
                //if (pathProExe == null) return;
                //pathProExe = Uri.UnescapeDataString(pathProExe);
                //pathProExe = System.IO.Path.Combine(pathProExe, @"Python\envs\arcgispro-py3");
                //// Create and format path to Python
                //var pathPython = System.IO.Path.GetDirectoryName((new System.Uri(Assembly.GetExecutingAssembly().CodeBase)).AbsolutePath);
                //if (pathPython == null) return;
                //pathPython = Uri.UnescapeDataString(pathPython);
                //// Create and format process command string.
                //// NOTE:  Path to Python script is below, "C:\temp\RunPython.py", which can be kept or updated based on the location you place it.
                //var myCommand = string.Format(@"/c """"{0}"" ""{1}""""",
                //    System.IO.Path.Combine(pathProExe, "python.exe"),
                //    System.IO.Path.Combine(pathPython, @"C:\EMESolutions\ProEmeTools\clearMd.py"));
                //// Create process start info, with instruction settings
                //var procStartInfo = new System.Diagnostics.ProcessStartInfo("cmd", myCommand);
                //procStartInfo.RedirectStandardOutput = true;
                //procStartInfo.RedirectStandardError = true;
                //procStartInfo.UseShellExecute = false;
                //procStartInfo.CreateNoWindow = true;
                //// Create process and start it
                //System.Diagnostics.Process proc = new System.Diagnostics.Process();
                //proc.StartInfo = procStartInfo;
                //proc.Start();
                //// Create and format result string
                //string result = proc.StandardOutput.ReadToEnd();
                //string error = proc.StandardError.ReadToEnd();
                //if (!string.IsNullOrEmpty(error)) result += string.Format("{0} Error: {1}", result, error);
                //// Show result string
                //ArcGIS.Desktop.Framework.Dialogs.MessageBox.Show(result, "Info");

                #endregion
            }

            catch (Exception exc)
            {
                // Catch any exception found and display in a message box
                ArcGIS.Desktop.Framework.Dialogs.MessageBox.Show("Exception caught while trying to run Python tool: " + exc.Message);
                return;
            }
            


        }
    }

    internal class EMEMenu_upgradeFgdcMD : Button
    {
        //private string _installPath = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);
        private string _pathEmeToolbox = System.Environment.GetFolderPath(System.Environment.SpecialFolder.ApplicationData) + "\\U.S. EPA\\EME Toolkit\\EMEProToolBox\\";
        protected override void OnClick()
        {
            try
            {

                string toolpath = _pathEmeToolbox + "\\EPA Pro Metadata Toolbox.pyt\\upgradeTool";
                Geoprocessing.OpenToolDialog(toolpath, null);

            }

            catch (Exception exc)
            {
                // Catch any exception found and display in a message box
                ArcGIS.Desktop.Framework.Dialogs.MessageBox.Show("Exception caught while trying to run Python tool: " + exc.Message);
                return;
            }

        }

    }

    internal class EMEMenu_importMD : Button
    {
        //private string _installPath = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);
        private string _pathEmeToolbox = System.Environment.GetFolderPath(System.Environment.SpecialFolder.ApplicationData) + "\\U.S. EPA\\EME Toolkit\\EMEProToolBox\\";
        protected override void OnClick()
        {
            try
            {           
             
                string toolpath = _pathEmeToolbox + "\\EPA Pro Metadata Toolbox.pyt\\importTool";
                Geoprocessing.OpenToolDialog(toolpath, null);
                
            }

            catch (Exception exc)
            {
                // Catch any exception found and display in a message box
                ArcGIS.Desktop.Framework.Dialogs.MessageBox.Show("Exception caught while trying to run Python tool: " + exc.Message);
                return;
            }

        }

    }
    internal class EMEMenu_cleanexportMD : Button
    {
        //private string _installPath = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);
        private string _pathEmeToolbox = System.Environment.GetFolderPath(System.Environment.SpecialFolder.ApplicationData) + "\\U.S. EPA\\EME Toolkit\\EMEProToolBox\\";
        protected override void OnClick()
        {
            try
            {

                string toolpath = _pathEmeToolbox + "\\EPA Pro Metadata Toolbox.pyt\\cleanExportTool";
                Geoprocessing.OpenToolDialog(toolpath, null);

            }

            catch (Exception exc)
            {
                // Catch any exception found and display in a message box
                MessageBox.Show("Exception caught while trying to run Python tool: " + exc.Message);
                return;
            }

        }
    }
    internal class EMEMenu_cleanUpToolMD : Button
    {
        //private string _installPath = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);
        private string _pathEmeToolbox = System.Environment.GetFolderPath(System.Environment.SpecialFolder.ApplicationData) + "\\U.S. EPA\\EME Toolkit\\EMEProToolBox\\";
        protected override void OnClick()
        {
            try
            {

                string toolpath = _pathEmeToolbox + "\\EPA Pro Metadata Toolbox.pyt\\cleanupTool";
                Geoprocessing.OpenToolDialog(toolpath, null);

            }

            catch (Exception exc)
            {
                // Catch any exception found and display in a message box
                ArcGIS.Desktop.Framework.Dialogs.MessageBox.Show("Exception caught while trying to run Python tool: " + exc.Message);
                return;
            }

        }
    }
    internal class EMEMenu_saveTemplateMD : Button
    {
        //private string _installPath = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);
        private string _pathEmeToolbox = System.Environment.GetFolderPath(System.Environment.SpecialFolder.ApplicationData) + "\\U.S. EPA\\EME Toolkit\\EMEProToolBox\\";
        protected override void OnClick()
        {
            try
            {

                string toolpath = _pathEmeToolbox + "\\EPA Pro Metadata Toolbox.pyt\\saveTemplate";
                Geoprocessing.OpenToolDialog(toolpath, null);

            }

            catch (Exception exc)
            {
                // Catch any exception found and display in a message box
                ArcGIS.Desktop.Framework.Dialogs.MessageBox.Show("Exception caught while trying to run Python tool: " + exc.Message);
                return;
            }

        }
    }
    internal class EMEMenu_editElementMD : Button
    {
        //private string _installPath = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);
        private string _pathEmeToolbox = System.Environment.GetFolderPath(System.Environment.SpecialFolder.ApplicationData) + "\\U.S. EPA\\EME Toolkit\\EMEProToolBox\\";
        protected override void OnClick()
        {
            try
            {

                string toolpath = _pathEmeToolbox + "\\EPA Pro Metadata Toolbox.pyt\\editElement";
                Geoprocessing.OpenToolDialog(toolpath, null);

            }

            catch (Exception exc)
            {
                // Catch any exception found and display in a message box
                ArcGIS.Desktop.Framework.Dialogs.MessageBox.Show("Exception caught while trying to run Python tool: " + exc.Message);
                return;
            }

        }
    }
    internal class EMEMenu_editDatesMD : Button
    {
        //private string _installPath = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);
        private string _pathEmeToolbox = System.Environment.GetFolderPath(System.Environment.SpecialFolder.ApplicationData) + "\\U.S. EPA\\EME Toolkit\\EMEProToolBox\\";
        protected override void OnClick()
        {
            try
            {

                string toolpath = _pathEmeToolbox + "\\EPA Pro Metadata Toolbox.pyt\\editDates";
                Geoprocessing.OpenToolDialog(toolpath, null);

            }

            catch (Exception exc)
            {
                // Catch any exception found and display in a message box
                ArcGIS.Desktop.Framework.Dialogs.MessageBox.Show("Exception caught while trying to run Python tool: " + exc.Message);
                return;
            }

        }
    }
    internal class EMEMenu_exportISOToolMD : Button
    {
        //private string _installPath = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);
        private string _pathEmeToolbox = System.Environment.GetFolderPath(System.Environment.SpecialFolder.ApplicationData) + "\\U.S. EPA\\EME Toolkit\\EMEProToolBox\\";
        protected override void OnClick()
        {
            try
            {

                string toolpath = _pathEmeToolbox + "\\EPA Pro Metadata Toolbox.pyt\\exportISOTool";
                Geoprocessing.OpenToolDialog(toolpath, null);
            }

            catch (Exception exc)
            {
                // Catch any exception found and display in a message box
                ArcGIS.Desktop.Framework.Dialogs.MessageBox.Show("Exception caught while trying to run Python tool: " + exc.Message);
                return;
            }

        }
    }
    internal class EMEMenu_mergeTemplateMD : Button
    {
        //private string _installPath = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);
        private string _pathEmeToolbox = System.Environment.GetFolderPath(System.Environment.SpecialFolder.ApplicationData) + "\\U.S. EPA\\EME Toolkit\\EMEProToolBox\\";
        protected override void OnClick()
        {
            try
            {

                string toolpath = _pathEmeToolbox + "\\EPA Pro Metadata Toolbox.pyt\\mergeTemplate";
                Geoprocessing.OpenToolDialog(toolpath, null);
                
            }

            catch (Exception exc)
            {
                // Catch any exception found and display in a message box
                Debug.WriteLine(exc.Message);
                Debug.WriteLine(exc.InnerException);
                ArcGIS.Desktop.Framework.Dialogs.MessageBox.Show("Exception caught while trying to run Python tool: " + exc.Message);
                return;
            }

        }
    }

    internal class EMEMenu_esriSyncMD : Button
    {
        //private string _installPath = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);
        private string _pathEmeToolbox = System.Environment.GetFolderPath(System.Environment.SpecialFolder.ApplicationData) + "\\U.S. EPA\\EME Toolkit\\EMEProToolBox\\";
        protected override void OnClick()
        {
            try
            {

                string toolpath = _pathEmeToolbox + "\\EPA Pro Metadata Toolbox.pyt\\esriSync";
                Geoprocessing.OpenToolDialog(toolpath, null);

            }

            catch (Exception exc)
            {
                // Catch any exception found and display in a message box
                Debug.WriteLine(exc.Message);
                Debug.WriteLine(exc.InnerException);
                ArcGIS.Desktop.Framework.Dialogs.MessageBox.Show("Exception caught while trying to run Python tool: " + exc.Message);
                return;
            }

        }
    }

    internal class EMEMenu_keywords2tags : Button
    {
        //private string _installPath = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);
        private string _pathEmeToolbox = System.Environment.GetFolderPath(System.Environment.SpecialFolder.ApplicationData) + "\\U.S. EPA\\EME Toolkit\\EMEProToolBox\\";
        protected override void OnClick()
        {
            try
            {
                string toolpath = _pathEmeToolbox + "\\EPA Pro Metadata Toolbox.pyt\\keywords2tags";
                Geoprocessing.OpenToolDialog(toolpath, null);
            }

            catch (Exception exc)
            {
                // Catch any exception found and display in a message box
                Debug.WriteLine(exc.Message);
                Debug.WriteLine(exc.InnerException);
                ArcGIS.Desktop.Framework.Dialogs.MessageBox.Show("Exception caught while trying to run Python tool: " + exc.Message);
                return;
            }
        }
    }

    internal class EMEMenu_EMEdb : Button
    {
        private string _installPath = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);
        protected override void OnClick()
        {
            Trace.WriteLine(Path.Combine(_installPath, "EMEdbManager", "EMEdbManager", "bin", "Debug", "EMEdbManager.exe"));
            Process.Start(Path.Combine(_installPath, "EMEdbManager", "EMEdbManager.exe"));

        }
    }
    internal class EMEMenu_ShowToolbox : Button
    {
        //private string _installPath = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);
        private string _pathEmeToolbox = System.Environment.GetFolderPath(System.Environment.SpecialFolder.ApplicationData) + "\\U.S. EPA\\EME Toolkit\\EMEProToolBox\\";
        protected override void OnClick()
        {
            string toolpath = _pathEmeToolbox + "\\EPA Pro Metadata Toolbox.pyt";
            MessageBox.Show(toolpath);

        }
    }
    //internal class EMEMenu_thumbnailBasemap : ComboBox
    //{
    //    private bool _isInitialized;
    //    public class thumbnailBasemap
    //    {
    //        public static string selected;
    //    }
    //    public EMEMenu_thumbnailBasemap()
    //    {
    //        getBasemaps();
    //    }
    //    private async void getBasemaps()
    //    {
    //        if (_isInitialized)
    //        {
    //            return;
    //        }
    //        _isInitialized = true;

    //        var namesAsArray = Enum.GetNames(typeof(Basemap));
    //        foreach(string nn in namesAsArray)
    //        {
    //            Add(nn.ToString() != null ? new ComboBoxItem(nn.ToString()) : new ComboBoxItem(string.Empty));
    //        }
    //        Enabled = true; //enables the ComboBox
    //        // default
    //        SelectedItem = ItemCollection[1];
            
    //    }
    //    protected override async void OnSelectionChange(ComboBoxItem item)
    //    {
    //        thumbnailBasemap.selected = item.Text;
    //    }

    //}

    internal class EMEMenu_SplitBasemap_ProjectDefault : Button
    {
        protected override void OnClick()
        {
            var thumbsup = new ThumbnailUpdater();
            thumbsup.ExportFrameAsync(basemap: "ProjectDefault");
        }
    }
    internal class EMEMenu_SplitBasemap_None : Button
    {
        protected override void OnClick()
        {
            var thumbsup = new ThumbnailUpdater();
            thumbsup.ExportFrameAsync(basemap: "None");
        }
    }
    internal class EMEMenu_SplitBasemap_Satellite : Button
    {
        protected override void OnClick()
        {
            var thumbsup = new ThumbnailUpdater();
            thumbsup.ExportFrameAsync(basemap: "Satellite");
        }
    }
    internal class EMEMenu_SplitBasemap_Hybrid : Button
    {
        protected override void OnClick()
        {
            var thumbsup = new ThumbnailUpdater();
            thumbsup.ExportFrameAsync(basemap: "Hybrid");
        }
    }
    internal class EMEMenu_SplitBasemap_Streets : Button
    {
        protected override void OnClick()
        {
            var thumbsup = new ThumbnailUpdater();
            thumbsup.ExportFrameAsync(basemap: "Streets");
        }
    }
    internal class EMEMenu_SplitBasemap_Topographic : Button
    {
        protected override void OnClick()
        {
            var thumbsup = new ThumbnailUpdater();
            thumbsup.ExportFrameAsync(basemap: "Topographic");
        }
    }
    internal class EMEMenu_SplitBasemap_DarkGray : Button
    {
        protected override void OnClick()
        {
            var thumbsup = new ThumbnailUpdater();
            thumbsup.ExportFrameAsync(basemap: "DarkGray");
        }
    }
    internal class EMEMenu_SplitBasemap_Gray : Button
    {
        protected override void OnClick()
        {
            var thumbsup = new ThumbnailUpdater();
            thumbsup.ExportFrameAsync(basemap: "Gray");
        }
    }
    internal class EMEMenu_SplitBasemap_NationalGeographic : Button
    {
        protected override void OnClick()
        {
            var thumbsup = new ThumbnailUpdater();
            thumbsup.ExportFrameAsync(basemap: "NationalGeographic");
        }
    }
    internal class EMEMenu_SplitBasemap_Oceans : Button
    {
        protected override void OnClick()
        {
            var thumbsup = new ThumbnailUpdater();
            thumbsup.ExportFrameAsync(basemap: "Oceans");
        }
    }
    internal class EMEMenu_SplitBasemap_Terrain : Button
    {
        protected override void OnClick()
        {
            var thumbsup = new ThumbnailUpdater();
            thumbsup.ExportFrameAsync(basemap: "Terrain");
        }
    }
    internal class EMEMenu_Nav2EMETools : Button
    {
        protected override void OnClick()
        {
            FrameworkApplication.ActivateTab("EMEProToolkit_Tab1");
        }
    }
    
    internal class EMEMenu_ProToolsChecked : Button
    {
        public EMEMenu_ProToolsChecked()
        {
            IsChecked = true;
            Caption = "Lock";
            LargeImage = new System.Windows.Media.Imaging.BitmapImage(new Uri(
       @"pack://application:,,,/ArcGIS.Desktop.Resources;component/Images/GenericLockNoColor32.png"));
        }

        protected override void OnClick()
        {
            IsChecked = !IsChecked;

            if (IsChecked)
            {
                FrameworkApplication.State.Deactivate("stock_metadata_tools_state");
                Caption = "Locked";
                Uri uriSource = new Uri(
        "pack://application:,,,/ArcGIS.Desktop.Resources;component/Images/GenericLockNoColor32.png");
                LargeImage = new System.Windows.Media.Imaging.BitmapImage(uriSource);
            }
            else
            {
                FrameworkApplication.State.Activate("stock_metadata_tools_state");
                Caption = "Unlocked";
                LargeImage = new System.Windows.Media.Imaging.BitmapImage(new Uri(
       @"pack://application:,,,/ArcGIS.Desktop.Resources;component/Images/GenericUnLockNoColor32.png"));
            }
        }
    }
}
