﻿#pragma checksum "..\..\..\Pages\MD_Format.xaml" "{8829d00f-11b8-4213-878b-770e8597ac16}" "819C58A0E07273E6FF6076558D0645B6A78EE4F27A932BE74D91E09B878B145A"
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
using EMEProToolkit.Properties;
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
    
    
    internal partial class MTK_MD_Format : ArcGIS.Desktop.Metadata.Editor.Pages.EditorPage, System.Windows.Markup.IComponentConnector {
        
        
        #line 80 "..\..\..\Pages\MD_Format.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.TextBox MD_Format_name;
        
        #line default
        #line hidden
        
        
        #line 87 "..\..\..\Pages\MD_Format.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.TextBox MD_Format_version;
        
        #line default
        #line hidden
        
        
        #line 93 "..\..\..\Pages\MD_Format.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.TextBox MD_Format_amendmentNumber;
        
        #line default
        #line hidden
        
        
        #line 99 "..\..\..\Pages\MD_Format.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.TextBox MD_Format_specification;
        
        #line default
        #line hidden
        
        
        #line 105 "..\..\..\Pages\MD_Format.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.TextBox MD_Format_fileDecompressionTechnique;
        
        #line default
        #line hidden
        
        
        #line 111 "..\..\..\Pages\MD_Format.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.TextBox FGDC_Distribution_formcont;
        
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
            System.Uri resourceLocater = new System.Uri("/EMEProToolkit;component/pages/md_format.xaml", System.UriKind.Relative);
            
            #line 1 "..\..\..\Pages\MD_Format.xaml"
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
            
            #line 25 "..\..\..\Pages\MD_Format.xaml"
            ((EMEProToolkit.Pages.MTK_MD_Format)(target)).Loaded += new System.Windows.RoutedEventHandler(this.FillXml);
            
            #line default
            #line hidden
            return;
            case 2:
            this.MD_Format_name = ((System.Windows.Controls.TextBox)(target));
            return;
            case 3:
            this.MD_Format_version = ((System.Windows.Controls.TextBox)(target));
            return;
            case 4:
            this.MD_Format_amendmentNumber = ((System.Windows.Controls.TextBox)(target));
            return;
            case 5:
            this.MD_Format_specification = ((System.Windows.Controls.TextBox)(target));
            return;
            case 6:
            this.MD_Format_fileDecompressionTechnique = ((System.Windows.Controls.TextBox)(target));
            return;
            case 7:
            this.FGDC_Distribution_formcont = ((System.Windows.Controls.TextBox)(target));
            return;
            }
            this._contentLoaded = true;
        }
    }
}

