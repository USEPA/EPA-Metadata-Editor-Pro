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
    public class AsyncContacts
    {
        XmlDocument _emeConfig = new XmlDocument();
        XmlDocument _contactsDoc = new XmlDocument();
        XmlDocument _contactsEsri = new XmlDocument();
        XmlDocument _contactsEpa = new XmlDocument();
        XmlDocument _contactsBAK = new XmlDocument();
        XmlDocument _contactsWEB = new XmlDocument();
        string _filePathEsri = Environment.GetFolderPath(Environment.SpecialFolder.Personal) + "\\ArcGIS\\Descriptions\\";
        string _filePathEme = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData) + "\\U.S. EPA\\EME Toolkit\\EMEdb\\";
        private string _installPath = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);

        public Task CopyContentsAsync(string srcDir, string targDir)
        {
            return Task.Run(() =>
            {
                if (!Directory.Exists(targDir))
                {
                    Directory.CreateDirectory(targDir);
                    //Trace.WriteLine("Created target directory: "+targDir);
                };
                foreach (var f in Directory.GetFiles(srcDir))
                {
                    string fname = Path.GetFileName(f);
                    //Trace.WriteLine("Copying " + fname);
                    string dest = Path.Combine(targDir, fname);
                    File.Copy(f, dest, overwrite: true);
                }
            });
        }

        public async void USEPADirAsync()
        {
            if (!Directory.Exists(_filePathEme))
            {
                string src = _installPath + "\\EMEdb\\";
                CopyContentsAsync(srcDir: src, targDir: _filePathEme);
            }
        }

        public Task LoadContactsAsync(bool checksyncage)
        {
            return Task.Run(() =>
            {
                FrameworkApplication.State.Activate("sync_contacts_state");
                ReloadContacts(checksyncage);
                FrameworkApplication.State.Deactivate("sync_contacts_state");

            });
        }
        private void ReloadContacts(bool checkage = true)
        {
            #region Load EME Configuration File
            // Load emeConfig.xml
            try { _emeConfig.Load(_filePathEme + "emeConfig.xml"); }
            catch (System.IO.FileNotFoundException)
            {
                _emeConfig.LoadXml(
                "<?xml version=\"1.0\" standalone=\"yes\"?> \n" +
                "<emeConfig> \n" +
                "  <xs:schema id=\"emeConfig\" xmlns=\"\" xmlns:xs=\"http://www.w3.org/2001/XMLSchema\" xmlns:msdata=\"urn:schemas-microsoft-com:xml-msdata\"> \n" +
                "    <xs:element name=\"emeControl\"> \n" +
                "      <xs:complexType> \n" +
                "        <xs:sequence> \n" +
                "          <xs:element name=\"controlName\" type=\"xs:string\"/> \n" +
                "          <xs:element name=\"param\" maxOccurs=\"10\" minOccurs=\"0\"> \n" +
                "            <xs:complexType mixed=\"true\"> \n" +
                "              <xs:attribute name=\"label\" type=\"xs:string\" use=\"required\" /> \n" +
                "            </xs:complexType> \n" +
                "          </xs:element> \n" +
                "          <xs:element name=\"url\" maxOccurs=\"10\" minOccurs=\"0\"> \n" +
                "            <xs:complexType mixed=\"true\"> \n" +
                "              <xs:attribute name=\"label\" type=\"xs:string\" use=\"required\" /> \n" +
                "            </xs:complexType> \n" +
                "          </xs:element> \n" +
                "          <xs:element name=\"date\" maxOccurs=\"10\" minOccurs=\"0\"> \n" +
                "            <xs:complexType mixed=\"true\"> \n" +
                "              <xs:attribute name=\"label\" type=\"xs:string\" use=\"required\" /> \n" +
                "            </xs:complexType> \n" +
                "          </xs:element> \n" +
                "          <xs:element name=\"required\" maxOccurs=\"10\" minOccurs=\"0\"> \n" +
                "            <xs:complexType mixed=\"true\"> \n" +
                "              <xs:attribute name=\"label\" type=\"xs:string\" use=\"required\" /> \n" +
                "            </xs:complexType> \n" +
                "          </xs:element> \n" +
                "        </xs:sequence> \n" +
                "      </xs:complexType> \n" +
                "    </xs:element> \n" +
                "    <xs:element name=\"emeControl\"> \n" +
                "      <xs:complexType> \n" +
                "        <xs:choice minOccurs=\"0\" maxOccurs=\"unbounded\"> \n" +
                "          <xs:element ref=\"emeControl\" /> \n" +
                "        </xs:choice> \n" +
                "      </xs:complexType> \n" +
                "    </xs:element> \n" +
                "  </xs:schema> \n" +
                "  <emeControl> \n" +
                "    <controlName>Contacts Manager</controlName> \n" +
                "    <param label=\"Contacts Source\">EPA Contact</param> \n" +
                "    <url label=\"Contacts URL\">https://edg.epa.gov/EME/contacts.xml</url> \n" +
                "    <date label=\"Local Cache\">2010-06-27T12:00:00-07:00</date> \n" +
                "  </emeControl> \n" +
                "</emeConfig>");
            }
            #endregion
            var directoryName = _emeConfig.SelectSingleNode("//emeControl[controlName[contains(. , 'Contacts Manager')]]/param").InnerText;
            var directoryUrl = _emeConfig.SelectSingleNode("//emeControl[controlName[contains(. , 'Contacts Manager')]]/url").InnerText;
            DateTime lastSync = DateTime.Parse(_emeConfig.SelectSingleNode("//emeControl[controlName[contains(. , 'Contacts Manager')]]/date").InnerText);
            TimeSpan syncAge = ((DateTime.Now) - lastSync);
            //var syncDays = syncAge.ToString("d'd 'h'h 'm'm 's's'");


            // Check to see if local file is older than 8 hours:
            //bool dbExpired = syncAge > (new TimeSpan(0, 8, 0, 0));
            // Check if contacts.bak exists
            // this is created during LoadList. If LoadList crashes, then contacts.xml will be corrupted
            // replace contacts.xml with contacts.bak
            if (File.Exists(_filePathEsri + "contacts.bak"))
            {
                File.Delete(_filePathEsri + "contacts.xml");
                File.Copy(_filePathEsri + "contacts.bak", _filePathEsri + "contacts.xml");
                File.Delete(_filePathEsri + "contacts.bak");
            }
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(directoryUrl);
            //one minute timeout
            request.Timeout = 60000;
            request.Method = "HEAD"; //test URL without downloading the content
            bool dosync = (!checkage | (checkage & (syncAge > (new TimeSpan(0, 8, 0, 0)))));
            if (dosync)

            {
                Notification syncnotification = new Notification();
                //syncnotification.Title = FrameworkApplication.Title;
                syncnotification.Title = "EPA Metadata Editor Pro";
                syncnotification.Message = $"Syncing Online Contacts... \n Last sync was {lastSync.ToString()}";
                syncnotification.ImageUrl = @"pack://application:,,,/ArcGIS.Desktop.Resources;component/Images/GenericRefresh32.png";
                ArcGIS.Desktop.Framework.FrameworkApplication.AddNotification(syncnotification);
                //MessageBoxResult fileCheck = MessageBox.Show("Local cache is " + syncDays + " old.\nLoading contacts from \"" + directoryName + "\"\n (" + directoryUrl + ")", "EME Contacts Manager", MessageBoxButton.OK, MessageBoxImage.Information);
                try
                {
                    using (HttpWebResponse response = (HttpWebResponse)request.GetResponse())
                    {
                        if (response.StatusCode.ToString() == "OK")
                        {
                            // Return contacts.xml Date Modified
                            try { _contactsWEB.Load(directoryUrl); }
                            catch (System.IO.FileNotFoundException)
                            {
                                _contactsWEB.LoadXml(
                                "<contacts> \n" +
                                "  <contact> \n" +
                                "    <editorSource></editorSource> \n" +
                                "    <editorDigest></editorDigest> \n" +
                                "    <rpIndName></rpIndName> \n" +
                                "    <rpOrgName></rpOrgName> \n" +
                                "    <rpPosName></rpPosName> \n" +
                                "    <editorSave></editorSave> \n" +
                                "    <rpCntInfo></rpCntInfo> \n" +
                                "  </contact> \n" +
                                "</contacts>");
                            }
                            _contactsWEB.Save(_filePathEme + "contacts.xml");

                            // Add timestamp to config file
                            _emeConfig.SelectSingleNode("//emeControl[controlName[contains(. , 'Contacts Manager')]]/date").InnerText = DateTime.Now.ToString("o");
                            _emeConfig.Save(_filePathEme + "emeConfig.xml");
                        }
                        else
                        {
                            MessageBoxResult webResponse = System.Windows.MessageBox.Show("Error loading contacts from " + directoryUrl + "." + "\n" + "EME contacts will be loaded from local cache.", "EME 5.0 Web Request", MessageBoxButton.OK, MessageBoxImage.Information);
                        }
                    }
                }
                catch (Exception weberror)
                {
                    {
                        MessageBoxResult result = System.Windows.MessageBox.Show(weberror.Message + "\n" + "EME contacts will be loaded from local cache.", "EME 5.0 Web Request", MessageBoxButton.OK, MessageBoxImage.Warning);
                    }
                }
            }
            else
            {
                //load recent contacts from local cache notification
                Notification nosyncnotification = new Notification();
                //syncnotification.Title = FrameworkApplication.Title;
                nosyncnotification.Title = "EPA Metadata Editor Pro";
                nosyncnotification.Message = $"Loading local contacts from {lastSync.ToString()}";
                nosyncnotification.ImageUrl = @"pack://application:,,,/ArcGIS.Desktop.Resources;component/Images/GenericOptions32.png";
                ArcGIS.Desktop.Framework.FrameworkApplication.AddNotification(nosyncnotification);
                //MessageBoxResult fileCheck = MessageBox.Show("Local cache is " + syncDays + " old.\nContacts will be loaded from local cache.", "EME Contacts Manager", MessageBoxButton.OK, MessageBoxImage.Information);
            }

            try { _contactsBAK.Load(_filePathEsri + "contacts.xml"); }
            catch (System.IO.FileNotFoundException)
            {
                _contactsBAK.LoadXml(
                "<contacts> \n" +
                "  <contact> \n" +
                "    <editorSource></editorSource> \n" +
                "    <editorDigest></editorDigest> \n" +
                "    <rpIndName></rpIndName> \n" +
                "    <rpOrgName></rpOrgName> \n" +
                "    <rpPosName></rpPosName> \n" +
                "    <editorSave></editorSave> \n" +
                "    <rpCntInfo></rpCntInfo> \n" +
                "  </contact> \n" +
                "</contacts>");
            }
            // save backup of user contacts.xml
            _contactsBAK.Save(_filePathEsri + "contacts.bak");

            try { _contactsEsri.Load(_filePathEsri + "contacts.xml"); }
            catch (System.IO.FileNotFoundException)
            {
                _contactsEsri.LoadXml(
                "<contacts> \n" +
                "  <contact> \n" +
                "    <editorSource></editorSource> \n" +
                "    <editorDigest></editorDigest> \n" +
                "    <rpIndName></rpIndName> \n" +
                "    <rpOrgName></rpOrgName> \n" +
                "    <rpPosName></rpPosName> \n" +
                "    <editorSave></editorSave> \n" +
                "    <rpCntInfo></rpCntInfo> \n" +
                "  </contact> \n" +
                "</contacts>");
            }

            try { _contactsEpa.Load(_filePathEme + "contacts.xml"); }
            catch (System.IO.FileNotFoundException)
            {
                _contactsEpa.LoadXml(
                "<contacts> \n" +
                "  <contact> \n" +
                "    <editorSource></editorSource> \n" +
                "    <editorDigest></editorDigest> \n" +
                "    <rpIndName></rpIndName> \n" +
                "    <rpOrgName></rpOrgName> \n" +
                "    <rpPosName></rpPosName> \n" +
                "    <editorSave></editorSave> \n" +
                "    <rpCntInfo></rpCntInfo> \n" +
                "  </contact> \n" +
                "</contacts>");
            }

            // new document
            XmlDocument cloneMerge = new XmlDocument();

            #region This method took 8.66 seconds to load contacts
            //try { cloneMerge.Load(_filePathEsri + "contacts.cfg"); }
            //catch
            //{
            //    MessageBoxResult contactsTest = MessageBox.Show("Could not load contacts.cfg", "EME Contacts Manager", MessageBoxButton.OK, MessageBoxImage.Information);
            //}
            #endregion

            #region This takes 8.00 seconds to load
            XmlNode contactsNodeMerge = cloneMerge.CreateElement("contacts");
            cloneMerge.AppendChild(contactsNodeMerge);

            // Populate contacts list with local contacts.xml and Agency Directory
            var listEsri = _contactsEsri.SelectNodes("//contact");
            var listEpa = _contactsEpa.SelectNodes("//contact");
            StringBuilder sb2 = new StringBuilder();
            foreach (XmlNode child in listEsri)
            {
                // remove editorSource
                XmlNode e1 = child.SelectSingleNode("editorSource");
                if (null != e1)
                {
                    e1.InnerText = "My Contacts";
                }

                e1 = child.SelectSingleNode("editorDigest");
                if (null != e1)
                {
                    string digest = Utils.Utils.GeneratePartyKey(child);
                    e1.InnerText = digest;
                }

                // save back localuser editorSource
                sb2.Append("<contact>");
                sb2.Append(child.InnerXml);
                sb2.Append("</contact>");
            }
            foreach (XmlNode child in listEpa)
            {
                // remove editorSource
                XmlNode e2 = child.SelectSingleNode("editorSource");
                if (null != e2)
                {
                    e2.InnerText = directoryName;
                }

                e2 = child.SelectSingleNode("editorDigest");
                if (null != e2)
                {
                    string digest = Utils.Utils.GeneratePartyKey(child);
                    e2.InnerText = digest;
                }

                e2 = child.SelectSingleNode("editorSave");
                if (null != e2)
                {
                    e2.InnerText = "False";
                }

                // save back epa editorSource
                sb2.Append("<contact>");
                sb2.Append(child.InnerXml);
                sb2.Append("</contact>");
            }

            // append to clone
            contactsNodeMerge.InnerXml = sb2.ToString();
            #endregion

            // save to file
            cloneMerge.Save(Utils.Utils.GetContactsFileLocation());
            //cloneMerge.Save(_filePathEsri + "contacts.cfg");

            // restore contacts.xml to original state
            _contactsBAK.Save(Utils.Utils.GetContactsFileLocation());

            // contacts.xml restored successfully. It is now safe to delete BAK file.
            if (File.Exists(_filePathEsri + "contacts.bak"))
            {
                File.Delete(_filePathEsri + "contacts.bak");
            }

            //done notification 
            Notification donenotification = new Notification();
            donenotification.Title = "EPA Metadata Editor Pro";
            donenotification.Message = "Contacts Loaded";
            donenotification.ImageUrl = @"pack://application:,,,/ArcGIS.Desktop.Resources;component/Images/GenericCheckMark32.png";
            ArcGIS.Desktop.Framework.FrameworkApplication.AddNotification(donenotification);
        }

        
    }
}

