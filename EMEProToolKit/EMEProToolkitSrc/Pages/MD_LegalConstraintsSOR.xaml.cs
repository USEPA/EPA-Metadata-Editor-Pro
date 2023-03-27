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
using System.Collections.Generic;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Navigation;

using System.Diagnostics;
using ArcGIS.Desktop.Metadata.Editor.Pages;

namespace EMEProToolkit.Pages
{
  /// <summary>
  /// Interaction logic for MD_LegalConstraints.xaml
  /// </summary>
  internal partial class MD_LegalConstraintsSOR : EditorPage
  {
    private string _pathEmeDb = System.Environment.GetFolderPath(System.Environment.SpecialFolder.ApplicationData) + "\\U.S. EPA\\EME Toolkit\\EMEdb\\";
    public MD_LegalConstraintsSOR()
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
      string dbname = "SystemofRecords.xml";
      xmldp.Source = new Uri(_pathEmeDb + dbname);
    }

    private void cboSystemNames_LostMouseCapture(object sender, MouseEventArgs e)
    {
      ListBox liBox = (ListBox)lbxLegalConstsOtherLimits;
      string testURL = "";
      foreach (var liBoxItem in liBox.Items)
      {
        var liBoxCont = liBox.ItemContainerGenerator.ContainerFromItem(liBoxItem);
        var liBoxChildren = AllChildren(liBoxCont);
        string tbxName = "tbxLegalConstsSystemURL";
        TextBox tbxLegalURL = (TextBox)liBoxChildren.First(c => c.Name == tbxName);
        string cboBoxName = "cboSystemNames";
        ComboBox cboSysName = (ComboBox)liBoxChildren.First(c => c.Name == cboBoxName);
        System.Xml.XmlElement xmlTest = (System.Xml.XmlElement)cboSysName.SelectedItem;
        tbxLegalURL.Text = cboSysName.Text;
        if (cboSysName.SelectedValue != null)
        {
          testURL = xmlTest.LastChild.InnerText;
          tbxLegalURL.Text = testURL;
        }
        tbxLegalURL.Focus();
        tbxChangeFocus.Focus();
      }
    }

    private void Hyperlink_RequestNavigate(object sender, RequestNavigateEventArgs e)
    {
      Process.Start(new ProcessStartInfo { FileName = e.Uri.AbsoluteUri, UseShellExecute = true });
      e.Handled = true;
    }
  }
}
