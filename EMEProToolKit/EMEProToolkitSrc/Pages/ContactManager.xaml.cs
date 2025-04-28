/*
Copyright 2019 Esri
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.​
*/

using System;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Xml;

using ArcGIS.Desktop.Framework;
using ArcGIS.Desktop.Metadata.Editors.ClassicEditor;
using ArcGIS.Desktop.Metadata.Editors.ClassicEditor.Pages;
using System.Net;
using System.IO;
using System.Diagnostics;

namespace EMEProToolkit.Pages
{
    internal class ContactManagerSidebarLabel : ISidebarLabel
    {
        string ISidebarLabel.SidebarLabel
        {
            get { return ContactManagerSidebarLabel.SidebarLabel; }
        }

        public static string SidebarLabel
        {
            get { return EMEProToolkit.Properties.Resources.CFG_LBL_CONTACT_MGR; }
        }
    }
    /// <summary>
    /// Interaction logic for MTK_ContactManager.xaml
    /// </summary>
    internal partial class MTK_ContactManager : EditorPage
    {
        XmlDocument _emeConfig = new();
        XmlDocument _contactsDoc = new();
        XmlDocument _contactsEsri = new();
        XmlDocument _contactsEpa = new();
        XmlDocument _contactsBAK = new();
        XmlDocument _contactsWEB = new();
        string _filePathEsri = Environment.GetFolderPath(Environment.SpecialFolder.Personal) + "\\ArcGIS\\Descriptions\\";
        string _filePathEme = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData) + "\\U.S. EPA\\EME Toolkit\\EMEdb\\";

        public string partySource = null;
        //private XmlDocument _contactsDoc = null;

        public MTK_ContactManager()
        {
            InitializeComponent();

            //LostFocus += ContactManager_LostFocus;
        }

        //bool _isContactsListDirty = false;
        //void ContactManager_LostFocus(object sender, RoutedEventArgs e)
        //{
        //    CommitChanges();
        //    ReloadContacts();
        //    //_isContactsListDirty = false;
        //}

        /// <summary>
        /// unload form
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override public void CommitChanges()
        {

            if (null == _contactsDoc)
                return;

            // new document
      XmlDocument clone = new XmlDocument();
            XmlNode contactsNode = clone.CreateElement("contacts");
            clone.AppendChild(contactsNode);

            // write back out the contacts marked saved
            var list = _contactsDoc.SelectNodes("//contact[editorSave='True']");
      StringBuilder sb = new StringBuilder();

            foreach (XmlNode child in list)
            {
                // remove elements
                //
                XmlNode e = child.SelectSingleNode("editorSource");
                if (null != e)
                {
                    child.RemoveChild(e);
                }

                e = child.SelectSingleNode("editorDigest");
                if (null != e)
                {
                    child.RemoveChild(e);
                }

                // remove role
                //
                e = child.SelectSingleNode("role");
                if (null != e)
                {
                    child.RemoveChild(e);
                }

                // save back unique key
                string digest = Utils.Utils.GeneratePartyKey(child);
                sb.Append("<contact>");
                sb.Append("<editorSource>external</editorSource>");
                sb.Append("<editorDigest>");
                sb.Append(digest);
                sb.Append("</editorDigest>");
                sb.Append(child.InnerXml);
                sb.Append("</contact>");
            }

            // append to clone
            contactsNode.InnerXml = sb.ToString();

            // save to file
            string file = Utils.Utils.GetContactsFileLocation();
            clone.Save(file);
        }


        public void UncheckBox(object sender, RoutedEventArgs e)
        {
            CheckBox cb = sender as CheckBox;
            if (null == cb)
                return;
            Nullable<bool> check = cb.IsChecked;

            XmlNode tagNode = cb.Tag as XmlNode;
            if (null == tagNode)
                return;

            //if (false == check && "external".Equals(tagNode.InnerText))
            if (false == check && "My Contacts".Equals(tagNode.InnerText))
            {
                //string message = Properties.Resources.MSGBOX_SAVE_MSG;
                //string caption = Properties.Resources.MSGBOX_SAVE_CAPTION;
                MessageBoxButton button = MessageBoxButton.YesNo;
                MessageBoxImage icon = MessageBoxImage.Warning;

                // show dialog
                MessageBoxResult result = ArcGIS.Desktop.Internal.Framework.DialogManager.ShowMessageBox(EMEProToolkit.Properties.Resources.LBL_CM_Confirm, EMEProToolkit.Properties.Resources.LBL_CM_ConfirmTitle, button, icon);

                switch (result)
                {
                    case MessageBoxResult.Yes:
                        //_isContactsListDirty = true;
                        break;
                    //DoSave();
                    //break;
                    case MessageBoxResult.No:
                        cb.IsChecked = true;
                        break;
                        //DoCancel();
                        //break;
                }
            }
        }

        /// <summary>
        /// load form
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        //public void LoadContacts(object sender, RoutedEventArgs e)
        //{
        //    ReloadContacts();
        //}

        public void LoadContacts(object sender, RoutedEventArgs e)
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
            TimeSpan syncAge = ((DateTime.Now) - (DateTime.Parse(_emeConfig.SelectSingleNode("//emeControl[controlName[contains(. , 'Contacts Manager')]]/date").InnerText)));
            var syncDays = syncAge.ToString("d'd 'h'h 'm'm 's's'");

            // Check to see if local file is older than 12 hours:
            //bool dbExpired = syncAge > (new TimeSpan(0, 12, 0, 0));
            // Check if contacts.bak exists
            // this is created during LoadList. If LoadList crashes, then contacts.xml will be corrupted
            // replace contacts.xml with contacts.bak
            if (File.Exists(_filePathEsri + "contacts.bak"))
            {
                File.Delete(_filePathEsri + "contacts.xml");
                File.Copy(_filePathEsri + "contacts.bak", _filePathEsri + "contacts.xml");
                File.Delete(_filePathEsri + "contacts.bak");
            }
            //HttpWebRequest request = (HttpWebRequest)WebRequest.Create(directoryUrl);
            ////request.Timeout = 15000;
            //request.Timeout = 25000;
            //request.Method = "HEAD"; //test URL without downloading the content

            //if (syncAge > (new TimeSpan(0, 12, 0, 0)))
            //{
            //    //MessageBoxResult fileCheck = MessageBox.Show("Local cache is " + syncDays + " old.\nLoading contacts from \"" + directoryName + "\"\n (" + directoryUrl + ")", "EME Contacts Manager", MessageBoxButton.OK, MessageBoxImage.Information);
            //    try
            //    {
            //        using (HttpWebResponse response = (HttpWebResponse)request.GetResponse())
            //        {
            //            if (response.StatusCode.ToString() == "OK")
            //            {
            //                // Return contacts.xml Date Modified
            //                try { _contactsWEB.Load(directoryUrl); }
            //                catch (System.IO.FileNotFoundException)
            //                {
            //                    _contactsWEB.LoadXml(
            //                    "<contacts> \n" +
            //                    "  <contact> \n" +
            //                    "    <editorSource></editorSource> \n" +
            //                    "    <editorDigest></editorDigest> \n" +
            //                    "    <rpIndName></rpIndName> \n" +
            //                    "    <rpOrgName></rpOrgName> \n" +
            //                    "    <rpPosName></rpPosName> \n" +
            //                    "    <editorSave></editorSave> \n" +
            //                    "    <rpCntInfo></rpCntInfo> \n" +
            //                    "  </contact> \n" +
            //                    "</contacts>");
            //                }
            //                _contactsWEB.Save(_filePathEme + "contacts.xml");

            //                // Add timestamp to config file
            //                _emeConfig.SelectSingleNode("//emeControl[controlName[contains(. , 'Contacts Manager')]]/date").InnerText = DateTime.Now.ToString("o");
            //                _emeConfig.Save(_filePathEme + "emeConfig.xml");
            //            }
            //            else
            //            {
            //                MessageBoxResult webResponse = MessageBox.Show("Error loading contacts from " + directoryUrl + "." + "\n" + "EME contacts will be loaded from local cache.", "EME 5.0 Web Request", MessageBoxButton.OK, MessageBoxImage.Information);
            //            }
            //        }
            //    }
            //    catch (Exception weberror)
            //    {
            //        {
            //            MessageBoxResult result = MessageBox.Show(weberror.Message + "\n" + "EME contacts will be loaded from local cache.", "EME 5.0 Web Request", MessageBoxButton.OK, MessageBoxImage.Warning);
            //        }
            //    }
            //}
            //else
            //{
            //    //MessageBoxResult fileCheck = MessageBox.Show("Local cache is " + syncDays + " old.\nContacts will be loaded from local cache.", "EME Contacts Manager", MessageBoxButton.OK, MessageBoxImage.Information);
            //}

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
            XmlDocument cloneMerge = new();

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
            StringBuilder sb2 = new();
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


            // generate contact list
            contactsListBox.ItemsSource = Utils.Utils.GenerateContactsList(_contactsDoc, this.DataContext);

            // restore contacts.xml to original state
            _contactsBAK.Save(Utils.Utils.GetContactsFileLocation());

            // contacts.xml restored successfully. It is now safe to delete BAK file.
            if (File.Exists(_filePathEsri + "contacts.bak"))
            {
                File.Delete(_filePathEsri + "contacts.bak");
            }

            //_contactsDoc = new XmlDocument();
            //contactsListBox.ItemsSource = Utils.Utils.GenerateContactsList(_contactsDoc, this.DataContext);

            var mdModule = FrameworkApplication.FindModule("esri_metadata_module") as IMetadataEditorHost;
            if (mdModule != null)
                mdModule.AddCommitPage(this);
        }

        #region ISidebarLabel Members

        public override string SidebarLabel
        {
            get { return ContactManagerSidebarLabel.SidebarLabel; }
        }

        #endregion
        private void contactsListBox_Loaded(object sender, RoutedEventArgs e)
        {
            if (contactsListBox.IsVisible == true)
            {
                partySource = "ListBox Visible";
            }
        }
    }
}
