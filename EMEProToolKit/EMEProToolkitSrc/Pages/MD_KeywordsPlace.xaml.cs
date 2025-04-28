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
    /// Interaction logic for MD_KeywordsPlace.xaml
    /// </summary>
    public partial class MD_KeywordsPlace : EditorPage
    {
        private List<string> _listPlaceK = new();
        private string _pathEmeDb = System.Environment.GetFolderPath(System.Environment.SpecialFolder.ApplicationData) + "\\U.S. EPA\\EME Toolkit\\EMEdb\\";
        public MD_KeywordsPlace()
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

        private void EditorPage_Loaded(object sender, RoutedEventArgs e)
        {
            FillXml();

            var xmldp = (XmlDataProvider)this.Resources["EPAData"];
            string dbname = "KeywordsPlace.xml";
            xmldp.Source = new Uri(_pathEmeDb + dbname);
        }

        private void chbxEpaPlacekey_Checked(object sender, RoutedEventArgs e)
        {
            CheckBox cbx = (CheckBox)sender;
            System.Xml.XmlElement xmlCheckBox = (System.Xml.XmlElement)cbx.Content;

            _listPlaceK.Add(xmlCheckBox.InnerText);
            _listPlaceK.Sort();
            _listPlaceK = _listPlaceK.Where(s => !string.IsNullOrWhiteSpace(s)).Distinct().ToList();
            tbxMDEpaPlaceK.Text = "";

            foreach (string s in _listPlaceK)
            {
                tbxMDEpaPlaceK.Text += s + System.Environment.NewLine;
            }
            tbxMDEpaPlaceK.Focus();
            cbx.Focus();
        }

        private void chbxEpaPlacekey_Unchecked(object sender, RoutedEventArgs e)
        {
            CheckBox cbx = (CheckBox)sender;
            System.Xml.XmlElement xmlCheckBox = (System.Xml.XmlElement)cbx.Content;

            _listPlaceK.Remove(xmlCheckBox.InnerText);
            tbxMDEpaPlaceK.Text = "";

            foreach (string s in _listPlaceK)
            {
                tbxMDEpaPlaceK.Text += s + System.Environment.NewLine;
            }
            tbxMDEpaPlaceK.Focus();
            cbx.Focus();
        }

        private void btnLoadDefaultPlaceK_Click(object sender, RoutedEventArgs e)
        {
            ListBox liBox = (ListBox)lbxEpaPlaceK;
            foreach (var liBoxItem in liBox.Items)
            {
                var liBoxCont = liBox.ItemContainerGenerator.ContainerFromItem(liBoxItem);
                var liBoxChildren = AllChildren(liBoxCont);
                var liBoxName = "chbxEpaPlacekey";
                var liBoxCtrl = (CheckBox)liBoxChildren.First(c => c.Name == liBoxName);
                System.Xml.XmlElement xmlTest = (System.Xml.XmlElement)liBoxCtrl.Content;
                if (xmlTest.NextSibling.InnerText.ToLower().Contains("true"))
                { liBoxCtrl.IsChecked = true; }
                else
                { liBoxCtrl.IsChecked = false; }
            }
        }

        private void btnClearPlaceK_Click(object sender, RoutedEventArgs e)
        {
            ListBox liBox = (ListBox)lbxEpaPlaceK;
            foreach (var liBoxItem in liBox.Items)
            {
                var liBoxCont = liBox.ItemContainerGenerator.ContainerFromItem(liBoxItem);
                var liBoxChildren = AllChildren(liBoxCont);
                var liBoxName = "chbxEpaPlacekey";
                var liBoxCtrl = (CheckBox)liBoxChildren.First(c => c.Name == liBoxName);
                liBoxCtrl.IsChecked = false;
            }
        }

        private void btnLoadMDThemeK_Click(object sender, RoutedEventArgs e)
        {
            //List<string> MDKeywords = new List<string>();
            //string[] strMDKeywords = tbxMDEpaPlaceK.Text.Split(new string[] { "\r\n", "\n" }, StringSplitOptions.RemoveEmptyEntries);
            //foreach (string s in strMDKeywords)
            //{
            //    MDKeywords.Add(s.Trim());
            //}
            //MDKeywords = MDKeywords.Where(s => !string.IsNullOrWhiteSpace(s)).Distinct().ToList();
            //MDKeywords.Sort();

            //ListBox liBox = (ListBox)lbxEpaPlaceK;
            //foreach (var liBoxItem in liBox.Items)
            //{
            //    var liBoxCont = liBox.ItemContainerGenerator.ContainerFromItem(liBoxItem);
            //    var liBoxChildren = AllChildren(liBoxCont);
            //    var liBoxName = "chbxEpaPlacekey";
            //    var liBoxCtrl = (CheckBox)liBoxChildren.First(c => c.Name == liBoxName);
            //    System.Xml.XmlElement xmlTest = (System.Xml.XmlElement)liBoxCtrl.Content;
            //    string searchKeyword = xmlTest.InnerText.Trim();
            //    liBoxCtrl.IsChecked = MDKeywords.Exists(s => s.Equals(xmlTest.InnerText.Trim()));
        }

        private void tbxMDEpaPlaceK_Loaded(object sender, RoutedEventArgs e)
        {
            //MessageBox triggers properly everything else crashes if not visible
            //MessageBox.Show("Place Theme Key")
            if (lbxEpaPlaceK.IsVisible == true)
            {
                List<string> MDKeywords = new();
                if (tbxMDEpaPlaceK.Text.Any())
                {
                    string[] strMDKeywords = tbxMDEpaPlaceK.Text.Split(new string[] { "\r\n", "\n" }, StringSplitOptions.RemoveEmptyEntries);
                    foreach (string s in strMDKeywords)
                    {
                        MDKeywords.Add(s.Trim());
                    }
                }
                MDKeywords = MDKeywords.Where(s => !string.IsNullOrWhiteSpace(s)).Distinct().ToList();
                MDKeywords.Sort();

                ListBox liBox = (ListBox)lbxEpaPlaceK;
                foreach (var liBoxItem in liBox.Items)
                {
                    var liBoxCont = liBox.ItemContainerGenerator.ContainerFromItem(liBoxItem);
                    var liBoxChildren = AllChildren(liBoxCont);
                    var liBoxName = "chbxEpaPlacekey";
                    var liBoxCtrl = (CheckBox)liBoxChildren.First(c => c.Name == liBoxName);
                    System.Xml.XmlElement xmlTest = (System.Xml.XmlElement)liBoxCtrl.Content;
                    liBoxCtrl.IsChecked = MDKeywords.Exists(s => s.Equals(xmlTest.InnerText.Trim()));
                }
            }
        }
    }
}
