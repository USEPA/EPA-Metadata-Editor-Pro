using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using ArcGIS.Desktop.Metadata.Editor.Pages;
using System.Windows.Data;

namespace EMEProToolkit.Pages
{
    /// <summary>
    /// Interaction logic for MD_KeywordsUser.xaml
    /// </summary>
    public partial class MD_KeywordsUser : EditorPage
    {
        private List<string> _listUserK = new List<string>();
        private string _pathEmeDb = System.Environment.GetFolderPath(System.Environment.SpecialFolder.ApplicationData) + "\\U.S. EPA\\EME Toolkit\\EMEdb\\";

        public MD_KeywordsUser()
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
            string dbname = "KeywordsUser.xml";
            xmldp.Source = new Uri(_pathEmeDb + dbname);
        }

        private void chbxEpaUserkey_Checked(object sender, RoutedEventArgs e)
        {
            CheckBox cbx = (CheckBox)sender;
            System.Xml.XmlElement xmlCheckBox = (System.Xml.XmlElement)cbx.Content;

            _listUserK.Add(xmlCheckBox.InnerText);
            _listUserK.Sort();
            _listUserK = _listUserK.Where(s => !string.IsNullOrWhiteSpace(s)).Distinct().ToList();
            tbxMDEpaUserK.Text = "";

            foreach (string s in _listUserK)
            {
                tbxMDEpaUserK.Text += s + System.Environment.NewLine;
            }
            tbxMDEpaUserK.Focus();
            cbx.Focus();
        }

        private void chbxEpaUserkey_Unchecked(object sender, RoutedEventArgs e)
        {
            CheckBox cbx = (CheckBox)sender;
            System.Xml.XmlElement xmlCheckBox = (System.Xml.XmlElement)cbx.Content;

            _listUserK.Remove(xmlCheckBox.InnerText);
            tbxMDEpaUserK.Text = "";

            foreach (string s in _listUserK)
            {
                tbxMDEpaUserK.Text += s + System.Environment.NewLine;
            }
            tbxMDEpaUserK.Focus();
            cbx.Focus();
        }

        private void btnLoadDefaultUserK_Click(object sender, RoutedEventArgs e)
        {
            ListBox liBox = (ListBox)lbxEpaUserK;
            foreach (var liBoxItem in liBox.Items)
            {
                var liBoxCont = liBox.ItemContainerGenerator.ContainerFromItem(liBoxItem);
                var liBoxChildren = AllChildren(liBoxCont);
                var liBoxName = "chbxEpaUserkey";
                var liBoxCtrl = (CheckBox)liBoxChildren.First(c => c.Name == liBoxName);
                System.Xml.XmlElement xmlTest = (System.Xml.XmlElement)liBoxCtrl.Content;
                if (xmlTest.NextSibling.InnerText.ToLower().Contains("true"))
                { liBoxCtrl.IsChecked = true; }
                else
                { liBoxCtrl.IsChecked = false; }
            }
        }

        private void btnClearUserK_Click(object sender, RoutedEventArgs e)
        {
            ListBox liBox = (ListBox)lbxEpaUserK;
            foreach (var liBoxItem in liBox.Items)
            {
                var liBoxCont = liBox.ItemContainerGenerator.ContainerFromItem(liBoxItem);
                var liBoxChildren = AllChildren(liBoxCont);
                var liBoxName = "chbxEpaUserkey";
                var liBoxCtrl = (CheckBox)liBoxChildren.First(c => c.Name == liBoxName);
                liBoxCtrl.IsChecked = false;
            }
        }

        private void tbxMDEpaUserK_Loaded(object sender, RoutedEventArgs e)
        {
            //MessageBox triggers properly everything else crashes if not visible
            //MessageBox.Show("User Theme Key")
            if (lbxEpaUserK.IsVisible == true)
            {
                List<string> MDKeywords = new List<string>();
                if (tbxMDEpaUserK.Text.Any())
                {
                    string[] strMDKeywords = tbxMDEpaUserK.Text.Split(new string[] { "\r\n", "\n" }, StringSplitOptions.RemoveEmptyEntries);
                    foreach (string s in strMDKeywords)
                    {
                        MDKeywords.Add(s.Trim());
                    }
                }
                MDKeywords = MDKeywords.Where(s => !string.IsNullOrWhiteSpace(s)).Distinct().ToList();
                MDKeywords.Sort();

                ListBox liBox = (ListBox)lbxEpaUserK;
                foreach (var liBoxItem in liBox.Items)
                {
                    var liBoxCont = liBox.ItemContainerGenerator.ContainerFromItem(liBoxItem);
                    var liBoxChildren = AllChildren(liBoxCont);
                    var liBoxName = "chbxEpaUserkey";
                    var liBoxCtrl = (CheckBox)liBoxChildren.First(c => c.Name == liBoxName);
                    System.Xml.XmlElement xmlTest = (System.Xml.XmlElement)liBoxCtrl.Content;
                    liBoxCtrl.IsChecked = MDKeywords.Exists(s => s.Equals(xmlTest.InnerText.Trim()));
                }
            }
        }
    }
}