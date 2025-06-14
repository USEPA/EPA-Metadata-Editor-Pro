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
using System.Windows;
using ArcGIS.Desktop.Metadata.Editors.ClassicEditor.Pages;

namespace EMEProToolkit.Pages
{
    /// <summary>
    /// Interaction logic for MTK_CI_ResponsiblePartyReadOnly.xaml
    /// </summary>
    internal partial class MTK_CI_ResponsiblePartyReadOnly : EditorPage
    {
        public MTK_CI_ResponsiblePartyReadOnly()
        {
            InitializeComponent();
        }

        public override string DefaultValue
        {
            get
            {
                return Utils.Utils.ExtractResponsiblePartyLabel(this, EMEProToolkit.Properties.Resources.LBL_CI_PARTY_READONLY_FORMAT);
            }

            set
            {
                // NOOP
            }
        }
        private void EditorPage_Loaded(object sender, RoutedEventArgs e)
        {
            FillXml();
            if (this.IsVisible == true)
            {
                //var dataContextXml = Utils.GetXmlDataContext(this.DataContext);
                //lblContactsFileLocation.Content = Utils.GetContactsFileLocation();
                //lblThisDataContextStr.Content = this.DataContext.ToString();
                //lblThisDataContext.Content = this.DataContext;
                //lblGetDataContext.Content = dataContextXml;
            }
        }
    }
}
