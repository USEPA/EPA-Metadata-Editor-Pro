using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Net;
using System.IO;
using System.Diagnostics;
using System.Xml;
using System.Windows;
using System.Windows.Controls;

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
using ArcGIS.Desktop.Mapping;
using ArcGIS.Desktop.Metadata;

namespace EMEProToolkit
{
    public class EMEInstall
    {
        XmlDocument _emeConfig = new XmlDocument();
        XmlDocument _contactsDoc = new XmlDocument();
        XmlDocument _contactsEsri = new XmlDocument();
        XmlDocument _contactsEpa = new XmlDocument();
        XmlDocument _contactsBAK = new XmlDocument();
        XmlDocument _contactsWEB = new XmlDocument();
        private string _filePathEsri = Environment.GetFolderPath(Environment.SpecialFolder.Personal) + "\\ArcGIS\\Descriptions\\";
        private string _filePathEme = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData) + "\\U.S. EPA\\EME Toolkit\\EMEdb\\";
        private string _installPath = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);

        public Task CopyDir(string srcDir, string targDir)
        {
            return Task.Run(() =>
            {
                //ArcGIS.Desktop.Framework.Dialogs.MessageBox.Show("CopyContentsAsync - copy contents task running");
                if (!Directory.Exists(targDir))
                {
                    //ArcGIS.Desktop.Framework.Dialogs.MessageBox.Show("CopyContentsAsync - creating target dir");

                    Directory.CreateDirectory(targDir);
                    //Trace.WriteLine("Created target directory: "+targDir);
                };
                //ArcGIS.Desktop.Framework.Dialogs.MessageBox.Show("CopyContentsAsync - copying contents");

                foreach (var f in Directory.GetFiles(srcDir))
                {
                    string fname = Path.GetFileName(f);
                    //Trace.WriteLine("Copying " + fname);
                    string dest = Path.Combine(targDir, fname);
                    File.Copy(f, dest, overwrite: true);
                }
            });
        }
        public void DirectionsDir()
        {
            if (!Directory.Exists(_filePathEsri))
            {
                Directory.CreateDirectory(_filePathEsri);
            }
        }

        public async void CheckUSEPADir()
        {
            //ArcGIS.Desktop.Framework.Dialogs.MessageBox.Show("USEPADirAsync - Check if Target US EPA dir: "+ _filePathEme);
            LogOutput.Log("USEPADirAsync - Check if Target US EPA dir: " + _filePathEme);

            if (!Directory.Exists(_filePathEme))
            {
                string src = _installPath + "\\EMEdb\\";
                //ArcGIS.Desktop.Framework.Dialogs.MessageBox.Show("USEPADirAsync - Creating US EPA db dir and copying contents from : " + src);
                LogOutput.Log("USEPADirAsync - Creating U.S. EPA dir at: " + _filePathEme);
                LogOutput.Log("USEPADirAsync - Source Dir: " + src);
                await CopyDir(srcDir: src, targDir: _filePathEme);
            }
        }
    }
}

        