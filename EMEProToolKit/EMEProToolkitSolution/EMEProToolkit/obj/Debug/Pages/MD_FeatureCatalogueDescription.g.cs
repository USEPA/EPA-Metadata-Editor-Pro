﻿#pragma checksum "..\..\..\Pages\MD_FeatureCatalogueDescription.xaml" "{8829d00f-11b8-4213-878b-770e8597ac16}" "B3C156301158F445D6CB449822F10787ECCCDF1D9A4A6B442637ECABF96BD426"
//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:4.0.30319.42000
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

using ArcGIS.Desktop.Metadata.Editor;
using ArcGIS.Desktop.Metadata.Editor.Pages;
using ArcGIS.Desktop.Metadata.Editor.Validation;
using ArcGIS.Desktop.Metadata.Pages.Converters;
using EMEProToolkit;
using EMEProToolkit.Pages;
using EMEProToolkit.Properties;
using EMEProToolkit.Utils;
using System;
using System.Diagnostics;
using System.Windows;
using System.Windows.Automation;
using System.Windows.Controls;
using System.Windows.Controls.Primitives;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Markup;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Media.Effects;
using System.Windows.Media.Imaging;
using System.Windows.Media.Media3D;
using System.Windows.Media.TextFormatting;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Windows.Shell;


namespace EMEProToolkit.Pages {
    
    
    internal partial class MTK_MD_FeatureCatalogueDescription : ArcGIS.Desktop.Metadata.Editor.Pages.EditorPage, System.Windows.Markup.IComponentConnector, System.Windows.Markup.IStyleConnector {
        
        
        #line 112 "..\..\..\Pages\MD_FeatureCatalogueDescription.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.CheckBox MD_FeatureCatalogueDescription_complianceCode;
        
        #line default
        #line hidden
        
        
        #line 118 "..\..\..\Pages\MD_FeatureCatalogueDescription.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.CheckBox MD_FeatureCatalogueDescription_includedWithDataset;
        
        #line default
        #line hidden
        
        
        #line 207 "..\..\..\Pages\MD_FeatureCatalogueDescription.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.Button MD_FeatureCatalogueDescription_FeaturetypeAdd;
        
        #line default
        #line hidden
        
        
        #line 250 "..\..\..\Pages\MD_FeatureCatalogueDescription.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.Button MD_FeatureCatalogueDescription_FeatureCatalogCitationAdd;
        
        #line default
        #line hidden
        
        private bool _contentLoaded;
        
        /// <summary>
        /// InitializeComponent
        /// </summary>
        [System.Diagnostics.DebuggerNonUserCodeAttribute()]
        [System.CodeDom.Compiler.GeneratedCodeAttribute("PresentationBuildTasks", "4.0.0.0")]
        public void InitializeComponent() {
            if (_contentLoaded) {
                return;
            }
            _contentLoaded = true;
            System.Uri resourceLocater = new System.Uri("/EMEProToolkit;component/pages/md_featurecataloguedescription.xaml", System.UriKind.Relative);
            
            #line 1 "..\..\..\Pages\MD_FeatureCatalogueDescription.xaml"
            System.Windows.Application.LoadComponent(this, resourceLocater);
            
            #line default
            #line hidden
        }
        
        [System.Diagnostics.DebuggerNonUserCodeAttribute()]
        [System.CodeDom.Compiler.GeneratedCodeAttribute("PresentationBuildTasks", "4.0.0.0")]
        [System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Never)]
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Design", "CA1033:InterfaceMethodsShouldBeCallableByChildTypes")]
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Maintainability", "CA1502:AvoidExcessiveComplexity")]
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1800:DoNotCastUnnecessarily")]
        void System.Windows.Markup.IComponentConnector.Connect(int connectionId, object target) {
            switch (connectionId)
            {
            case 1:
            
            #line 28 "..\..\..\Pages\MD_FeatureCatalogueDescription.xaml"
            ((EMEProToolkit.Pages.MTK_MD_FeatureCatalogueDescription)(target)).Loaded += new System.Windows.RoutedEventHandler(this.FillXml);
            
            #line default
            #line hidden
            return;
            case 2:
            this.MD_FeatureCatalogueDescription_complianceCode = ((System.Windows.Controls.CheckBox)(target));
            return;
            case 3:
            this.MD_FeatureCatalogueDescription_includedWithDataset = ((System.Windows.Controls.CheckBox)(target));
            return;
            case 9:
            this.MD_FeatureCatalogueDescription_FeaturetypeAdd = ((System.Windows.Controls.Button)(target));
            
            #line 206 "..\..\..\Pages\MD_FeatureCatalogueDescription.xaml"
            this.MD_FeatureCatalogueDescription_FeaturetypeAdd.Click += new System.Windows.RoutedEventHandler(this.AddRecordByTagToLocal);
            
            #line default
            #line hidden
            return;
            case 11:
            this.MD_FeatureCatalogueDescription_FeatureCatalogCitationAdd = ((System.Windows.Controls.Button)(target));
            
            #line 249 "..\..\..\Pages\MD_FeatureCatalogueDescription.xaml"
            this.MD_FeatureCatalogueDescription_FeatureCatalogCitationAdd.Click += new System.Windows.RoutedEventHandler(this.AddRecordByTagToLocal);
            
            #line default
            #line hidden
            return;
            }
            this._contentLoaded = true;
        }
        
        [System.Diagnostics.DebuggerNonUserCodeAttribute()]
        [System.CodeDom.Compiler.GeneratedCodeAttribute("PresentationBuildTasks", "4.0.0.0")]
        [System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Never)]
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Design", "CA1033:InterfaceMethodsShouldBeCallableByChildTypes")]
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1800:DoNotCastUnnecessarily")]
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Maintainability", "CA1502:AvoidExcessiveComplexity")]
        void System.Windows.Markup.IStyleConnector.Connect(int connectionId, object target) {
            switch (connectionId)
            {
            case 4:
            
            #line 134 "..\..\..\Pages\MD_FeatureCatalogueDescription.xaml"
            ((System.Windows.Controls.Button)(target)).Click += new System.Windows.RoutedEventHandler(this.AddRecordByTagToLocal);
            
            #line default
            #line hidden
            break;
            case 5:
            
            #line 142 "..\..\..\Pages\MD_FeatureCatalogueDescription.xaml"
            ((System.Windows.Controls.Button)(target)).Click += new System.Windows.RoutedEventHandler(this.DeleteItem);
            
            #line default
            #line hidden
            break;
            case 6:
            
            #line 150 "..\..\..\Pages\MD_FeatureCatalogueDescription.xaml"
            ((System.Windows.Controls.ComboBox)(target)).Loaded += new System.Windows.RoutedEventHandler(this.PostProcessComboBoxValues);
            
            #line default
            #line hidden
            break;
            case 7:
            
            #line 162 "..\..\..\Pages\MD_FeatureCatalogueDescription.xaml"
            ((System.Windows.Controls.ComboBox)(target)).Loaded += new System.Windows.RoutedEventHandler(this.PostProcessComboBoxValues);
            
            #line default
            #line hidden
            break;
            case 8:
            
            #line 189 "..\..\..\Pages\MD_FeatureCatalogueDescription.xaml"
            ((System.Windows.Controls.Button)(target)).Click += new System.Windows.RoutedEventHandler(this.DeleteItem);
            
            #line default
            #line hidden
            break;
            case 10:
            
            #line 231 "..\..\..\Pages\MD_FeatureCatalogueDescription.xaml"
            ((System.Windows.Controls.Button)(target)).Click += new System.Windows.RoutedEventHandler(this.DeleteItem);
            
            #line default
            #line hidden
            break;
            }
        }
    }
}

