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

using System.Windows.Controls;
using ArcGIS.Desktop.Metadata.Editor.Pages;
using System;
using System.Linq;
using System.Windows;
using System.Windows.Data;
using System.Windows.Navigation;
using System.Diagnostics;

namespace EMEProToolkit.Pages
{
  /// <summary>
  /// Interaction logic for MTK_MD_SecurityConstraints.xaml
  /// </summary>
  internal partial class MD_SecurityConstraintsEME : EditorPage
  {
    private string _pathEmeDb = System.Environment.GetFolderPath(System.Environment.SpecialFolder.ApplicationData) + "\\U.S. EPA\\EME Toolkit\\EMEdb\\";
    public MD_SecurityConstraintsEME()
    {
      InitializeComponent();
    }

    private void EditorPage_Loaded(object sender, RoutedEventArgs e)
    {
      FillXml();

      var xmldp = (XmlDataProvider)this.Resources["EPAData"];
      string dbname = "SecurityConstraints.xml";
      xmldp.Source = new Uri(_pathEmeDb + dbname);
    }

    private void cboEpaSecUseNote_LostFocus(object sender, RoutedEventArgs e)
    {
      tbxConstsUserNote.Text = cboEpaSecUseNote.Text;
      tbxConstsUserNote.Focus();
    }

    private void cboEpaSecUseNote_Loaded(object sender, RoutedEventArgs e)
    {
      if (cboEpaSecUseNote.IsVisible == true)
      {
        if (tbxConstsUserNote.Text.Any())
        {
          cboEpaSecUseNote.Text = tbxConstsUserNote.Text;
        }
      }
    }

    private void Hyperlink_RequestNavigate(object sender, RequestNavigateEventArgs e)
    {
      Process.Start(new ProcessStartInfo(e.Uri.AbsoluteUri));
      e.Handled = true;
    }
  }
}
