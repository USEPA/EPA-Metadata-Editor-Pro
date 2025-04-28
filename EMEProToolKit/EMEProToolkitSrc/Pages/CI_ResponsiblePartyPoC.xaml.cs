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

using System.ComponentModel;
using ArcGIS.Desktop.Metadata.Editors.ClassicEditor.Pages;

namespace EMEProToolkit.Pages
{
    /// <summary>
    /// Interaction logic for CI_ResponsiblePartyPoC.xaml
    /// </summary>
    internal partial class CI_ResponsiblePartyPoC : EditorPage, INotifyPropertyChanged
    {
        public CI_ResponsiblePartyPoC()
        {
            InitializeComponent();
        }

        public override string DefaultValue
        {
            get
            {
                return Utils.Utils.ExtractResponsiblePartyLabel(this, EMEProToolkit.Properties.Resources.LBL_CI_PARTY_FORMAT);
            }

            set
            {
                // NOOP
            }
        }
    }
}
