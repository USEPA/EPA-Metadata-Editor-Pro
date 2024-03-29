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
using System.ComponentModel;
using System.Windows;
using ArcGIS.Desktop.Metadata.Editor.Pages;
using System.Windows.Navigation;
using System.Diagnostics;

namespace EMEProToolkit.Pages
{
    /// <summary>
    /// Interaction logic for MTK_CI_Citation.xaml
    /// </summary>
    internal partial class MTK_CI_Citation : EditorPage, INotifyPropertyChanged
    {
        public MTK_CI_Citation()
        {
            InitializeComponent();
        }

        public static readonly DependencyProperty SupressPartiesProperty = DependencyProperty.Register(
           "SupressParties",
           typeof(Boolean),
           typeof(MTK_CI_Citation));

        public static readonly DependencyProperty SupressOnlineResourceProperty = DependencyProperty.Register(
           "SupressOnlineResource",
           typeof(Boolean),
           typeof(MTK_CI_Citation));

        public Boolean SupressParties
        {
            get { return (Boolean)this.GetValue(SupressPartiesProperty); }
            set { this.SetValue(SupressPartiesProperty, value); }
        }

        public Boolean SupressOnlineResource
        {
            get { return (Boolean)this.GetValue(SupressOnlineResourceProperty); }
            set { this.SetValue(SupressOnlineResourceProperty, value); }
        }
        private void Hyperlink_RequestNavigate(object sender, RequestNavigateEventArgs e)
        {
            //New method (.NET 6 https://learn.microsoft.com/en-us/answers/questions/809281/net6-system-diagnostics-process-start-error)
            Process.Start(new ProcessStartInfo { FileName = e.Uri.AbsoluteUri, UseShellExecute = true });
            e.Handled = true;
        }

    }
}
