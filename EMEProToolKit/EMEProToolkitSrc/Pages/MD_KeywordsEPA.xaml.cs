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
using System.Diagnostics;


namespace EMEProToolkit.Pages
{
    /// <summary>
    /// Interaction logic for MD_KeywordsEPA.xaml
    /// </summary>
    internal partial class MD_KeywordsEPA : EditorPage
    {
        private List<string> _listThemeK = new();
        private string _pathEmeDb = System.Environment.GetFolderPath(System.Environment.SpecialFolder.ApplicationData) + "\\U.S. EPA\\EME Toolkit\\EMEdb\\";

        public MD_KeywordsEPA()
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

        private void MD_KeywordsEPA_Loaded(object sender, RoutedEventArgs e)
        {
            FillXml();

            var xmldp = (XmlDataProvider)this.Resources["EPAData"];
            string dbname = "KeywordsEPA.xml";
            xmldp.Source = new Uri(_pathEmeDb + dbname);
        }

        private void chbxEpaThemekey_Checked(object sender, RoutedEventArgs e)
        {
            CheckBox cbx = (CheckBox)sender;
            System.Xml.XmlElement xmlCheckBox = (System.Xml.XmlElement)cbx.Content;

            _listThemeK.Add(xmlCheckBox.InnerText);
            _listThemeK.Sort();
            _listThemeK = _listThemeK.Where(s => !string.IsNullOrWhiteSpace(s)).Distinct().ToList();
            tbxMDEpaThemeK.Text = "";

            foreach (string s in _listThemeK)
            {
                tbxMDEpaThemeK.Text += s + System.Environment.NewLine;
            }
            tbxMDEpaThemeK.Focus();
            cbx.Focus();
        }

        private void chbxEpaThemekey_Unchecked(object sender, RoutedEventArgs e)
        {
            CheckBox cbx = (CheckBox)sender;
            System.Xml.XmlElement xmlCheckBox = (System.Xml.XmlElement)cbx.Content;

            _listThemeK.Remove(xmlCheckBox.InnerText);
            tbxMDEpaThemeK.Text = "";

            foreach (string s in _listThemeK)
            {
                tbxMDEpaThemeK.Text += s + System.Environment.NewLine;
            }
            tbxMDEpaThemeK.Focus();
            cbx.Focus();
        }

        private void btnLoadDefaultThemeK_Click(object sender, RoutedEventArgs e)
        {
            ListBox liBox = (ListBox)lbxEpaThemeK;
            foreach (var liBoxItem in liBox.Items)
            {
                var liBoxCont = liBox.ItemContainerGenerator.ContainerFromItem(liBoxItem);
                var liBoxChildren = AllChildren(liBoxCont);
                var liBoxName = "chbxEpaThemekey";
                var liBoxCtrl = (CheckBox)liBoxChildren.First(c => c.Name == liBoxName);
                System.Xml.XmlElement xmlTest = (System.Xml.XmlElement)liBoxCtrl.Content;
                if (xmlTest.NextSibling.InnerText.ToLower().Contains("true"))
                { liBoxCtrl.IsChecked = true; }
                else
                { liBoxCtrl.IsChecked = false; }
            }
        }

        private void btnClearThemeK_Click(object sender, RoutedEventArgs e)
        {
            ListBox liBox = (ListBox)lbxEpaThemeK;
            foreach (var liBoxItem in liBox.Items)
            {
                var liBoxCont = liBox.ItemContainerGenerator.ContainerFromItem(liBoxItem);
                var liBoxChildren = AllChildren(liBoxCont);
                var liBoxName = "chbxEpaThemekey";
                var liBoxCtrl = (CheckBox)liBoxChildren.First(c => c.Name == liBoxName);
                liBoxCtrl.IsChecked = false;
            }
        }

        private void tbxMDEpaThemeK_Loaded(object sender, RoutedEventArgs e)
        {
            //MessageBox triggers properly everything else crashes if not visible
            //MessageBox.Show("EPA Keywords Metadata" + "\n" + "tbxMDEpaThemeK.Loaded" + "\n" + "IsEnabled = " + tbxMDEpaThemeK.IsEnabled.ToString() + "\n" + "IsVisible = " + tbxMDEpaThemeK.IsVisible.ToString());
            if (lbxEpaThemeK.IsVisible == true)
            {
                List<string> MDKeywords = new();
                if (tbxMDEpaThemeK.Text.Any())
                {
                    string[] strMDKeywords = tbxMDEpaThemeK.Text.Split(new string[] { "\r\n", "\n" }, StringSplitOptions.RemoveEmptyEntries);
                    foreach (string s in strMDKeywords)
                    {
                        MDKeywords.Add(s.Trim());
                    }
                }
                MDKeywords = MDKeywords.Where(s => !string.IsNullOrWhiteSpace(s)).Distinct().ToList();
                MDKeywords.Sort();

                ListBox liBox = (ListBox)lbxEpaThemeK;
                foreach (var liBoxItem in liBox.Items)
                {
                    var liBoxCont = liBox.ItemContainerGenerator.ContainerFromItem(liBoxItem);
                    var liBoxChildren = AllChildren(liBoxCont);
                    var liBoxName = "chbxEpaThemekey";
                    var liBoxCtrl = (CheckBox)liBoxChildren.First(c => c.Name == liBoxName);
                    System.Xml.XmlElement xmlTest = (System.Xml.XmlElement)liBoxCtrl.Content;
                    liBoxCtrl.IsChecked = MDKeywords.Exists(s => s.Equals(xmlTest.InnerText.Trim()));
                }
            }
        }
    }
}
