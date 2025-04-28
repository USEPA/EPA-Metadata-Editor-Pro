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

using ArcGIS.Desktop.Metadata.Editors.ClassicEditor.Pages;
using ArcGIS.Desktop.Metadata.Editors.ClassicEditor;


namespace EMEProToolkit.Pages
{
    /// <summary>
    /// Interaction logic for MD_KeywordsCode.xaml
    /// </summary>
    public partial class MD_KeywordsCode : EditorPage
    {
        private List<string> _listPCode = new();
        private string _pathEmeDb = System.Environment.GetFolderPath(System.Environment.SpecialFolder.ApplicationData) + "\\U.S. EPA\\EME Toolkit\\EMEdb\\";

        public MD_KeywordsCode()
        {
            InitializeComponent();
        }

        public List<Control> AllChildren(DependencyObject parent)
        {
            var _List = new List<Control> { };
            for (int i = 0; i < VisualTreeHelper.GetChildrenCount(parent); i++)
            {
                var _Child = VisualTreeHelper.GetChild(parent, i);
                if (_Child is Control)
                    _List.Add(_Child as Control);
                _List.AddRange(AllChildren(_Child));
            }
            return _List;
        }

        private void MD_KeywordsCode_Loaded(object sender, RoutedEventArgs e)
        {
            FillXml();

            var xmldp = (XmlDataProvider)this.Resources["EPAData"];
            string dbname = "ProgramCode.xml";
            xmldp.Source = new Uri(_pathEmeDb + dbname);
        }

        private void chbxPCode_Checked(object sender, RoutedEventArgs e)
        {
            CheckBox cbx = (CheckBox)sender;
            System.Xml.XmlElement xmlCheckBox = (System.Xml.XmlElement)cbx.Content;

            _listPCode.Add(xmlCheckBox.InnerText);
            _listPCode.Sort();
            _listPCode = _listPCode.Where(s => !string.IsNullOrWhiteSpace(s)).Distinct().ToList();
            tbxMDPCode.Text = "";

            foreach (string s in _listPCode)
            {
                tbxMDPCode.Text += s + System.Environment.NewLine;
            }
            tbxMDPCode.Focus();
            cbx.Focus();
        }

        private void chbxPCode_Unchecked(object sender, RoutedEventArgs e)
        {
            CheckBox cbx = (CheckBox)sender;
            System.Xml.XmlElement xmlCheckBox = (System.Xml.XmlElement)cbx.Content;

            _listPCode.Remove(xmlCheckBox.InnerText);
            tbxMDPCode.Text = "";

            foreach (string s in _listPCode)
            {
                tbxMDPCode.Text += s + System.Environment.NewLine;
            }
            tbxMDPCode.Focus();
            cbx.Focus();

        }

        private void btnLoadDefaultPCode_Click(object sender, RoutedEventArgs e)
        {
            ListBox liBox = (ListBox)lbxPCode;
            foreach (var liBoxItem in liBox.Items)
            {
                var liBoxCont = liBox.ItemContainerGenerator.ContainerFromItem(liBoxItem);
                var liBoxChildren = AllChildren(liBoxCont);
                var liBoxName = "chbxPCode";
                var liBoxCtrl = (CheckBox)liBoxChildren.First(c => c.Name == liBoxName);
                System.Xml.XmlElement xmlTest = (System.Xml.XmlElement)liBoxCtrl.Content;
                if (xmlTest.NextSibling.InnerText.Contains("true"))
                { liBoxCtrl.IsChecked = true; }
                else
                { liBoxCtrl.IsChecked = false; }
            }
        }

        private void btnClearPCode_Click(object sender, RoutedEventArgs e)
        {
            ListBox liBox = (ListBox)lbxPCode;
            foreach (var liBoxItem in liBox.Items)
            {
                var liBoxCont = liBox.ItemContainerGenerator.ContainerFromItem(liBoxItem);
                var liBoxChildren = AllChildren(liBoxCont);
                var liBoxName = "chbxPCode";
                var liBoxCtrl = (CheckBox)liBoxChildren.First(c => c.Name == liBoxName);
                liBoxCtrl.IsChecked = false;
            }
        }

        private void tbxPCode_Loaded(object sender, RoutedEventArgs e)
        {
            if (lbxPCode.IsVisible == true)
            {
                List<string> listPCode = new();
                if (tbxMDPCode.Text.Any())
                {
                    string[] strlistPCode = tbxMDPCode.Text.Split(new string[] { "\r\n", "\n" }, StringSplitOptions.RemoveEmptyEntries);
                    foreach (string s in strlistPCode)
                    {
                        listPCode.Add(s.Trim());
                    }
                }
                listPCode = listPCode.Where(s => !string.IsNullOrWhiteSpace(s)).Distinct().ToList();
                listPCode.Sort();

                ListBox liBox = (ListBox)lbxPCode;
                foreach (var liBoxItem in liBox.Items)
                {
                    var liBoxCont = liBox.ItemContainerGenerator.ContainerFromItem(liBoxItem);
                    var liBoxChildren = AllChildren(liBoxCont);
                    var chbxName = "chbxPCode";
                    var chBoxCtrl = (CheckBox)liBoxChildren.First(c => c.Name == chbxName);
                    var lblName = "lblPName";
                    var lblCtrl = (Label)liBoxChildren.First(c => c.Name == lblName);
                    System.Xml.XmlElement xmlTest = (System.Xml.XmlElement)chBoxCtrl.Content;
                    chBoxCtrl.IsChecked = listPCode.Exists(s => s.Equals(xmlTest.InnerText.Trim()));
                }
            }
        }
    }
}
