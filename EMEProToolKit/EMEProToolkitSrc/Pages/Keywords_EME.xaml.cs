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

using ArcGIS.Desktop.Metadata;
using ArcGIS.Desktop.Metadata.Editor.Pages;
using System.Windows.Navigation;
using System.Diagnostics;
using System;

namespace EMEProToolkit.Pages
{
    /// <summary>
    /// Interaction logic for KeywordsEME.xaml
    /// </summary>
    internal partial class Keywords_EME : EditorPage
    {
        public Keywords_EME()
        {
        InitializeComponent();
        }

        public override string SidebarLabel
        {
            get { return EMEProToolkit.Properties.Resources.CFG_LBL_KEYWORDS; }
            //get { return "TEST: Topics & Keywords"; }
        }

        private void Hyperlink_RequestNavigate(object sender, RequestNavigateEventArgs e)
        {
            Process.Start(new ProcessStartInfo(e.Uri.AbsoluteUri));
            e.Handled = true;
        }
    }
}
