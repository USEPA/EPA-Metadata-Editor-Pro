using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Net;
using System.IO;
using System.Xml;
using ArcGIS.Desktop.Framework;
using ArcGIS.Desktop.Metadata.Editor.Pages;
using ArcGIS.Desktop.Metadata;
using ArcGIS.Desktop.Metadata.Editor;
using System.Diagnostics;




namespace EMEProToolkit.Pages
{
    /// <summary>
    /// Interaction logic for PartyPickerControlEME.xaml
    /// </summary>
    public partial class PartyPickerControlEME : EditorPage
    {
        XmlDocument _emeConfig = new();
        XmlDocument _contactsDoc = new();
        XmlDocument _contactsEsri = new();
        XmlDocument _contactsEpa = new();
        XmlDocument _contactsBAK = new();
        XmlDocument _contactsWEB = new();
        string _filePathEsri = Environment.GetFolderPath(Environment.SpecialFolder.Personal) + "\\ArcGIS\\Descriptions\\";
        string _filePathEme = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData) + "\\U.S. EPA\\EME Toolkit\\EMEdb\\";

        public string ContainerElement { get; set; }

        public PartyPickerControlEME()
        {
            InitializeComponent();
        }

        public void LoadList(object sender, EventArgs e)
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

            // check if local file is older than 12 hours
            bool dbExpired = syncAge > (new TimeSpan(0, 12, 0, 0));

            // Check to see if contacts.bak exists.
            // contacts.bak is created during LoadList. If LoadList crashes contacts.xml will be left with bad data.
            // replace contacts.xml with contacts.bak
            if (File.Exists(_filePathEsri + "contacts.bak"))
            {
                File.Delete(_filePathEsri + "contacts.xml");
                File.Copy(_filePathEsri + "contacts.bak", _filePathEsri + "contacts.xml");
                File.Delete(_filePathEsri + "contacts.bak");
            }

            //HttpWebRequest request = (HttpWebRequest)WebRequest.Create("https://edg.epa.gov/EME/contacts.xml");
            ////request.Timeout = 15000;
            //request.Timeout = 25000;
            //request.Method = "HEAD"; //test URL without downloading the content
            //if (syncAge > (new TimeSpan(0, 12, 0, 0)))
            //{
            //    //messageboxresult filecheck = messagebox.show("local cache is " + syncdays + " old.\nloading contacts from \"" + directoryname + "\"\n (" + directoryurl + ")", "eme contacts manager", messageboxbutton.ok, messageboximage.information);
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
            XmlDocument clone = new();
            XmlNode contactsNode = clone.CreateElement("contacts");
            clone.AppendChild(contactsNode);

            // Combine local contacts.xml with EPA contacts
            var listEsri = _contactsEsri.SelectNodes("//contact[editorSave='True']");
            var listEpa = _contactsEpa.SelectNodes("//contact");
            StringBuilder sb = new();
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
                sb.Append("<contact>");
                sb.Append(child.InnerXml);
                sb.Append("</contact>");
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
                    string digest =Utils.Utils.GeneratePartyKey(child);
                    e2.InnerText = digest;
                }

                e2 = child.SelectSingleNode("editorSave");
                if (null != e2)
                {
                    e2.InnerText = "True";
                }

                // save back epa editorSource
                sb.Append("<contact>");
                sb.Append(child.InnerXml);
                sb.Append("</contact>");
            }

            // append to clone
            contactsNode.InnerXml = sb.ToString();

            // save to file
            clone.Save(Utils.Utils.GetContactsFileLocation());

            // create display name for combobox
            var list = Utils.Utils.GenerateContactsList(_contactsDoc, this.DataContext);
            //_contactsDoc.Save(_filePathEme + "contactsDoc.xml");

            //XDocument doc = XDocument.Load(_filePathEme + "contactsDoc.xml");
            //XElement dealsParent = doc.Element("contacts");
            //dealsParent.ReplaceNodes(dealsParent.Nodes().Cast<XElement>().OrderByDescending(element => element.Element("displayName").Value));
            //doc.Save(_filePathEme + "contactsSort.xml");

            //XPathDocument myXPathDoc = new XPathDocument(_filePathEme + "contactsDoc.xml");
            //XslCompiledTransform myXslTrans = new XslCompiledTransform();
            //myXslTrans.Load(_filePathEme + "myStyleSheet.xslt");
            //XmlTextWriter myWriter = new XmlTextWriter(_filePathEme + "contactsResult.xml", null);
            //myXslTrans.Transform(myXPathDoc, null, myWriter);

            foreach (XmlNode node in list)
            {
                // get ONE good name for display
                //var nameNode = node.SelectSingleNode("rpIndName | rpOrgName | rpPosName");
                //var nameString = "unknown";
                //if (null != nameNode && 0 < nameNode.InnerText.Length)
                //{
                //    nameString = nameNode.InnerText + " test";
                //}

                string nameString = "unknown";
                string sourceString = "From Metadata Record";
                var nameString1 = Utils.Utils.ExtractResponsiblePartyLabel(node, EMEProToolkit.Properties.Resources.LBL_CI_PARTY_ADD_FORMAT);
                var sourceNode = node.SelectSingleNode("editorSource");

                if (null != sourceNode && 0 < sourceNode.InnerText.Length)
                {
                    sourceString = sourceNode.InnerText;
                    nameString = "[" + sourceString + "]   " + nameString1;
                }
                else
                {
                    nameString = "[" + sourceString + "]   " + nameString1;
                }

                // create new node for display in the list control
                var newNode = _contactsDoc.CreateElement("displayName");
                newNode.InnerText = nameString;
                node.AppendChild(newNode);
            }

            // return list
            PartyList.ItemsSource = list;

            // Restore contacts.xml to original state
            _contactsBAK.Save(Utils.Utils.GetContactsFileLocation());

            // LoadList complete and contacts.xml restored successfully. Safe to delete BAK file.
            if (File.Exists(_filePathEsri + "contacts.bak"))
            {
                File.Delete(_filePathEsri + "contacts.bak");
            }

        }

        public void LoadParty(object sender, EventArgs e)
        {
            // new xml to be inserted
            XmlNode selectedNode = PartyList.SelectedItem as XmlNode;
            if (null == selectedNode)
                return; // nothing selected

            string newXml = selectedNode.InnerXml;

            // get the context node
            var dataContextXml = Utils.Utils.GetXmlDataContext(this.DataContext);
            if (null == dataContextXml)
                return;

            XmlNode contextNode = null;
            foreach (XmlNode node in dataContextXml)
            {
                contextNode = node;
                break;
            }

            // add new xml to a container element, then add the container to the datacontext node
            if (null != newXml && 0 < newXml.Length && null != ContainerElement && 0 < ContainerElement.Length)
            {

                // create container node
                var containerNode = contextNode.OwnerDocument.CreateElement(ContainerElement);
                containerNode.InnerXml = newXml;

                // add to data context
                contextNode.AppendChild(containerNode);
            }
        }
    }
}
