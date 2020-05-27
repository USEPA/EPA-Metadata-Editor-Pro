﻿#pragma checksum "..\..\..\Pages\MD_ImageDescription.xaml" "{8829d00f-11b8-4213-878b-770e8597ac16}" "7CB813686BDE2687306675727B589D97CFA31A58657266257E696B44AA8DCAED"
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
using EMEProToolkit.Pages;
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
    
    
    internal partial class MTK_MD_ImageDescription : ArcGIS.Desktop.Metadata.Editor.Pages.EditorPage, System.Windows.Markup.IComponentConnector, System.Windows.Markup.IStyleConnector {
        
        
        #line 149 "..\..\..\Pages\MD_ImageDescription.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.TextBox MD_ImageDescription_illuminationElevationAngle;
        
        #line default
        #line hidden
        
        
        #line 156 "..\..\..\Pages\MD_ImageDescription.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.TextBox MD_ImageDescription_illuminationAzimuthAngle;
        
        #line default
        #line hidden
        
        
        #line 165 "..\..\..\Pages\MD_ImageDescription.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.ComboBox MD_ImageDescription_imagingCondition;
        
        #line default
        #line hidden
        
        
        #line 230 "..\..\..\Pages\MD_ImageDescription.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.TextBox MD_ImageDescription_cloudCoverPercentage;
        
        #line default
        #line hidden
        
        
        #line 291 "..\..\..\Pages\MD_ImageDescription.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.TextBox MD_ImageDescription_compressionGenerationQuantity;
        
        #line default
        #line hidden
        
        
        #line 296 "..\..\..\Pages\MD_ImageDescription.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.CheckBox MD_ImageDescription_triangulationIndicator;
        
        #line default
        #line hidden
        
        
        #line 298 "..\..\..\Pages\MD_ImageDescription.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.CheckBox MD_ImageDescription_radiometricCalibrationDataAvailability;
        
        #line default
        #line hidden
        
        
        #line 300 "..\..\..\Pages\MD_ImageDescription.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.CheckBox MD_ImageDescription_cameraCalibrationInformationAvailability;
        
        #line default
        #line hidden
        
        
        #line 302 "..\..\..\Pages\MD_ImageDescription.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.CheckBox MD_ImageDescription_filmDistortionInformationAvailability;
        
        #line default
        #line hidden
        
        
        #line 304 "..\..\..\Pages\MD_ImageDescription.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.CheckBox MD_ImageDescription_lensDistortionInformationAvailability;
        
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
            System.Uri resourceLocater = new System.Uri("/EMEProToolkit;component/pages/md_imagedescription.xaml", System.UriKind.Relative);
            
            #line 1 "..\..\..\Pages\MD_ImageDescription.xaml"
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
            
            #line 26 "..\..\..\Pages\MD_ImageDescription.xaml"
            ((EMEProToolkit.Pages.MTK_MD_ImageDescription)(target)).Loaded += new System.Windows.RoutedEventHandler(this.FillXml);
            
            #line default
            #line hidden
            return;
            case 2:
            this.MD_ImageDescription_illuminationElevationAngle = ((System.Windows.Controls.TextBox)(target));
            return;
            case 3:
            this.MD_ImageDescription_illuminationAzimuthAngle = ((System.Windows.Controls.TextBox)(target));
            return;
            case 4:
            this.MD_ImageDescription_imagingCondition = ((System.Windows.Controls.ComboBox)(target));
            
            #line 160 "..\..\..\Pages\MD_ImageDescription.xaml"
            this.MD_ImageDescription_imagingCondition.Loaded += new System.Windows.RoutedEventHandler(this.PostProcessComboBoxValues);
            
            #line default
            #line hidden
            return;
            case 7:
            this.MD_ImageDescription_cloudCoverPercentage = ((System.Windows.Controls.TextBox)(target));
            return;
            case 10:
            this.MD_ImageDescription_compressionGenerationQuantity = ((System.Windows.Controls.TextBox)(target));
            return;
            case 11:
            this.MD_ImageDescription_triangulationIndicator = ((System.Windows.Controls.CheckBox)(target));
            return;
            case 12:
            this.MD_ImageDescription_radiometricCalibrationDataAvailability = ((System.Windows.Controls.CheckBox)(target));
            return;
            case 13:
            this.MD_ImageDescription_cameraCalibrationInformationAvailability = ((System.Windows.Controls.CheckBox)(target));
            return;
            case 14:
            this.MD_ImageDescription_filmDistortionInformationAvailability = ((System.Windows.Controls.CheckBox)(target));
            return;
            case 15:
            this.MD_ImageDescription_lensDistortionInformationAvailability = ((System.Windows.Controls.CheckBox)(target));
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
            case 5:
            
            #line 187 "..\..\..\Pages\MD_ImageDescription.xaml"
            ((System.Windows.Controls.Button)(target)).Click += new System.Windows.RoutedEventHandler(this.DeleteItem);
            
            #line default
            #line hidden
            break;
            case 6:
            
            #line 213 "..\..\..\Pages\MD_ImageDescription.xaml"
            ((System.Windows.Controls.Button)(target)).Click += new System.Windows.RoutedEventHandler(this.AddRecordByTagToLocal);
            
            #line default
            #line hidden
            break;
            case 8:
            
            #line 248 "..\..\..\Pages\MD_ImageDescription.xaml"
            ((System.Windows.Controls.Button)(target)).Click += new System.Windows.RoutedEventHandler(this.DeleteItem);
            
            #line default
            #line hidden
            break;
            case 9:
            
            #line 274 "..\..\..\Pages\MD_ImageDescription.xaml"
            ((System.Windows.Controls.Button)(target)).Click += new System.Windows.RoutedEventHandler(this.AddRecordByTagToLocal);
            
            #line default
            #line hidden
            break;
            }
        }
    }
}

