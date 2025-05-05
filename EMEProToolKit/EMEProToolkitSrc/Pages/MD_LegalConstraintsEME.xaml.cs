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

using System.Collections.Generic;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Navigation;
using System.Diagnostics;
using ArcGIS.Desktop.Metadata.Editors.ClassicEditor.Pages;

namespace EMEProToolkit.Pages
{
  /// <summary>
  /// Interaction logic for MD_LegalConstraints.xaml
  /// </summary>
  internal partial class MD_LegalConstraintsEME : EditorPage
  {
    public MD_LegalConstraintsEME()
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

    private void btnAddSORN_Click(object sender, RoutedEventArgs e)
    {
      //tbxConstsUserNote.Text = cboEpaSecUseNote.Text;
      //tbxConstsUserNote.Focus();

      ListBox liBox = (ListBox)lbxLegalConstsUseLimit;
      foreach (var liBoxItem in liBox.Items)
      {
        var liBoxCont = liBox.ItemContainerGenerator.ContainerFromItem(liBoxItem);
        var liBoxChildren = AllChildren(liBoxCont);
        var liBoxName = "tbxUseLimit";
        var liBoxCtrl = (TextBox)liBoxChildren.First(c => c.Name == liBoxName);
        liBoxCtrl.Text = "FederalRegister.gov System of Records Notice";
        liBoxCtrl.Focus();
      }
      tbxChangeFocus.Focus();
    }

    private void Hyperlink_RequestNavigate(object sender, RequestNavigateEventArgs e)
    {
      Process.Start(new ProcessStartInfo { FileName = e.Uri.AbsoluteUri, UseShellExecute = true });
      e.Handled = true;
    }

    private void btnAddEpaDL_Click(object sender, RoutedEventArgs e)
    {
      ListBox liBox = (ListBox)lbxLegalConstsUseLimit;
      foreach (var liBoxItem in liBox.Items)
      {
        var liBoxCont = liBox.ItemContainerGenerator.ContainerFromItem(liBoxItem);
        var liBoxChildren = AllChildren(liBoxCont);
        var liBoxName = "tbxUseLimit";
        var liBoxCtrl = (TextBox)liBoxChildren.First(c => c.Name == liBoxName);
        liBoxCtrl.Text = "EPA Public Domain License";
        liBoxCtrl.Focus();
      }
      tbxChangeFocus.Focus();
    }

    private void AddToLocalSoRN(object sender, RoutedEventArgs e)
    {
      //add othConsts xml node
      btnAddToLocalSoRN.Tag = "Other";
      AddRecordByTagToLocal(sender, e);

      //add useLimit xml node
      btnAddToLocalSoRN.Tag = "UseLimit";
      AddRecordByTagToLocal(sender, e);

      //update useLimit content
      tbxUseLimitType.Focus();
      tbxUseLimitType.Text = "FederalRegister.gov System of Records Notice";
      tbxChangeFocus.Focus();
    }

    private void AddToLocalDataLic(object sender, RoutedEventArgs e)
    {
      //add othConsts xml node
      btnAddToLocalDataLic.Tag = "Other";
      AddRecordByTagToLocal(sender, e);

      //add useLimit xml node
      btnAddToLocalDataLic.Tag = "UseLimit";
      AddRecordByTagToLocal(sender, e);

      //update useLimit content
      tbxUseLimitType.Focus();
      tbxUseLimitType.Text = "EPA Public Domain License";
      tbxChangeFocus.Focus();
    }
  }
}
