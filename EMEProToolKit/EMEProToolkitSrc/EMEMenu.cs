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
using System.Windows.Controls.Primitives;

namespace EMEProToolkit
{
    
    public class EMEMenu_UpdateContacts : ArcGIS.Desktop.Framework.Contracts.Button
    {
        protected override void OnClick()
        {
            //TODO: Create/reference Async Process for updating contacts
            var AsyncContacts = new AsyncContacts();
            AsyncContacts.LoadContactsAsync(checksyncage:false);
        }
    }
    internal class EMEMenu_test : Button
    {
        protected override async void OnClick()
        {
            await QueuedTask.Run(() =>
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
        
    internal class EMEMenu_UpdateThumbnail : Button
    {
        public const string MyStateID = "preview_map_state";
        protected override void OnClick()
        {
            var thumbsup = new ThumbnailUpdater();
            thumbsup.ExportFrameAsync();

            //var window = FrameworkApplication.ActiveWindow as ArcGIS.Desktop.Core.IProjectWindow;

            ////MessageBox.Show(window.SelectionCount.ToString());

            //foreach (var pane in FrameworkApplication.Panes)
            //{
            //    string z = pane.GetType().ToString();
            //}

            //string s = FrameworkApplication.ActiveWindow.ToString();
            // int c = Project.Current.SelectedItems.Count;
            
                   
            ////IProjectWindow ipv = ArcGIS.Desktop.Core.IProjectWindow;
            //var commandId = @"esri_core_previewCaptureThumbnail";
            //var iCommand = FrameworkApplication.GetPlugInWrapper(commandId) as ICommand;
            ////if (iCommand != null)
            ////{
            ////    if (iCommand.CanExecute(null)) iCommand.Execute(null);
            ////    System.Windows.MessageBox.Show("it worked?");
            ////}


            //string f = FrameworkApplication.State.ToString();
            ////System.Windows.MessageBox.Show(s);
            ////System.Windows.MessageBox.Show(c.ToString());

        }
    }

    internal class EMEMenu_clearMD : Button
    {
        private string _pathEmeDb = System.Environment.GetFolderPath(System.Environment.SpecialFolder.ApplicationData) + "\\U.S. EPA\\EME Toolkit\\EMEProToolBox\\";
        protected override void OnClick()
        {            
            try
            {                    
                string j = "";
                var arguments = Geoprocessing.MakeValueArray(j);
                string toolpath = @_pathEmeDb+"EPA Pro Metadata Toolbox.tbx\\EPAClearRecord";
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
        protected override void OnClick()
        {

        }

    }

    internal class EMEMenu_importMD : Button
    {
        protected override void OnClick()
        {

        }

    }
    internal class EMEMenu_exportMD : Button
    {
        protected override void OnClick()
        {


        }
    }
    internal class EMEMenu_TESTBUTTON : Button
    {
        
        protected override void OnClick()
        {

            
        }
    }
}
