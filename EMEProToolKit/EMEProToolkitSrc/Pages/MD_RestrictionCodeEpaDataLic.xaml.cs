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
using ArcGIS.Desktop.Metadata.Editors.ClassicEditor.Pages;
using System.Collections.Generic;
using System.Windows;
using System.Windows.Input;
using System.Windows.Media;


namespace EMEProToolkit.Pages
{
  /// <summary>
  /// Interaction logic for MTK_MD_RestrictionCodeEpaDataLic.xaml
  /// </summary>
  internal partial class MD_RestrictionCodeEpaDataLic : EditorPage
  {
    public MD_RestrictionCodeEpaDataLic()
    {
      InitializeComponent();
    }
    private void lblRestrictCd_Loaded(object sender, RoutedEventArgs e)
    {
      tbkRestrictCd.Text = "009";
      tbkRestrictName.Text = "Unrestricted License";
      tbkRestrictUrl.Text = "https://edg.epa.gov/EPA_Data_License.html";
    }
  }
}
