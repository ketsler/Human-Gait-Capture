﻿#pragma checksum "..\..\FeatureID.xaml" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "56F1234AF182349457321B2769D474E2"
//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:4.0.30319.42000
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

using GaitID;
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


namespace GaitID {
    
    
    /// <summary>
    /// FeatureID
    /// </summary>
    public partial class FeatureID : System.Windows.Window, System.Windows.Markup.IComponentConnector {
        
        
        #line 17 "..\..\FeatureID.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.Button captureNavButton;
        
        #line default
        #line hidden
        
        
        #line 20 "..\..\FeatureID.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.Button featureNavButton;
        
        #line default
        #line hidden
        
        
        #line 23 "..\..\FeatureID.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.Button multivariateNavButton;
        
        #line default
        #line hidden
        
        
        #line 26 "..\..\FeatureID.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.Button patternNavButton;
        
        #line default
        #line hidden
        
        
        #line 29 "..\..\FeatureID.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.Button TestBenchNavButton;
        
        #line default
        #line hidden
        
        
        #line 32 "..\..\FeatureID.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.Label FileSelectLabel;
        
        #line default
        #line hidden
        
        
        #line 33 "..\..\FeatureID.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.Button BrowseButton;
        
        #line default
        #line hidden
        
        
        #line 35 "..\..\FeatureID.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.TextBox FileSaveLocationTextBox;
        
        #line default
        #line hidden
        
        
        #line 37 "..\..\FeatureID.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.Button IdentifyButton;
        
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
            System.Uri resourceLocater = new System.Uri("/GaitID;component/featureid.xaml", System.UriKind.Relative);
            
            #line 1 "..\..\FeatureID.xaml"
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
            this.captureNavButton = ((System.Windows.Controls.Button)(target));
            
            #line 18 "..\..\FeatureID.xaml"
            this.captureNavButton.Click += new System.Windows.RoutedEventHandler(this.CaptureNavButton_OnClick);
            
            #line default
            #line hidden
            return;
            case 2:
            this.featureNavButton = ((System.Windows.Controls.Button)(target));
            return;
            case 3:
            this.multivariateNavButton = ((System.Windows.Controls.Button)(target));
            return;
            case 4:
            this.patternNavButton = ((System.Windows.Controls.Button)(target));
            return;
            case 5:
            this.TestBenchNavButton = ((System.Windows.Controls.Button)(target));
            
            #line 30 "..\..\FeatureID.xaml"
            this.TestBenchNavButton.Click += new System.Windows.RoutedEventHandler(this.TestBenchButton_OnClick);
            
            #line default
            #line hidden
            return;
            case 6:
            this.FileSelectLabel = ((System.Windows.Controls.Label)(target));
            return;
            case 7:
            this.BrowseButton = ((System.Windows.Controls.Button)(target));
            
            #line 34 "..\..\FeatureID.xaml"
            this.BrowseButton.Click += new System.Windows.RoutedEventHandler(this.BrowseButton_OnClick);
            
            #line default
            #line hidden
            return;
            case 8:
            this.FileSaveLocationTextBox = ((System.Windows.Controls.TextBox)(target));
            return;
            case 9:
            this.IdentifyButton = ((System.Windows.Controls.Button)(target));
            
            #line 38 "..\..\FeatureID.xaml"
            this.IdentifyButton.Click += new System.Windows.RoutedEventHandler(this.IdentifyButton_OnClick);
            
            #line default
            #line hidden
            return;
            }
            this._contentLoaded = true;
        }
    }
}

