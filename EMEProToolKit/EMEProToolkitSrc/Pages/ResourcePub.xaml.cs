﻿/*
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
using System.Windows.Navigation;
using System.Diagnostics;
using ArcGIS.Desktop.Metadata;
using ArcGIS.Desktop.Metadata.Editor.Pages;

namespace EMEProToolkit.Pages
{
  internal class ResourcePubSidebarLabel : ISidebarLabel
  {
    string ISidebarLabel.SidebarLabel
    {
      get { return ResourcePubSidebarLabel.SidebarLabel; }
    }

    public static string SidebarLabel
    {
      get { return EMEProToolkit.Properties.Resources.CFG_LBL_RESOURCEPOC; }
    }
  }
  /// <summary>
  /// Interaction logic for MTK_ResourcePoc.xaml
  /// </summary>
  internal partial class ResourcePub : EditorPage
  {
    public ResourcePub()
    {
      InitializeComponent();
    }

    public override string SidebarLabel
    {
      //get { return ResourcePubSidebarLabel.SidebarLabel; }
      get { return "Publisher"; }
    }
    private void Hyperlink_RequestNavigate(object sender, RequestNavigateEventArgs e)
    {
      Process.Start(new ProcessStartInfo(e.Uri.AbsoluteUri));
      e.Handled = true;

    }
  }
}
