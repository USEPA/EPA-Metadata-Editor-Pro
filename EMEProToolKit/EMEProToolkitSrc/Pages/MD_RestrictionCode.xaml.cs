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
    /// Interaction logic for MTK_MD_RestrictionCode.xaml
    /// </summary>
    internal partial class MTK_MD_RestrictionCode : EditorPage
    {
        public MTK_MD_RestrictionCode()
        {
            InitializeComponent();
        }
    public static IEnumerable<T> FindVisualChildren<T>(DependencyObject depObj) where T : DependencyObject
    {
      if (depObj != null)
      {
        for (int i = 0; i < VisualTreeHelper.GetChildrenCount(depObj); i++)
        {
          DependencyObject child = VisualTreeHelper.GetChild(depObj, i);
          if (child != null && child is T)
          {
            yield return (T)child;
          }

          foreach (T childOfChild in FindVisualChildren<T>(child))
          {
            yield return childOfChild;
          }
        }
      }
    }

    public static childItem FindVisualChild<childItem>(DependencyObject obj)
        where childItem : DependencyObject
    {
      foreach (childItem child in FindVisualChildren<childItem>(obj))
      {
        return child;
      }
      return null;
    }

    private void cboRestrictCd_SelectionChanged(object sender, SelectionChangedEventArgs e)
    {
      ComboBox cbo = (ComboBox)sender;
      ContentPresenter contentPresenter = FindVisualChild<ContentPresenter>(cbo);
      DataTemplate dTemplate = contentPresenter.ContentTemplate;
      TextBlock textClassLbl = (TextBlock)dTemplate.FindName("tbkClassLabel", contentPresenter);
      if (textClassLbl != null)
      {
        tbkRestrictName.Text = textClassLbl.Text;
      }
    }

    private void cboRestrictCd_LostFocus(object sender, RoutedEventArgs e)
    {
      ComboBox cbo = (ComboBox)sender;
      ContentPresenter contentPresenter = FindVisualChild<ContentPresenter>(cbo);
      DataTemplate dTemplate = contentPresenter.ContentTemplate;
      TextBlock textClassLbl = (TextBlock)dTemplate.FindName("tbkClassLabel", contentPresenter);
      if (textClassLbl != null)
      {
        tbkRestrictName.Text = textClassLbl.Text;
      }
    }

    private void cboRestrictCd_LostMouseCapture(object sender, MouseEventArgs e)
    {
      ComboBox cbo = (ComboBox)sender;
      ContentPresenter contentPresenter = FindVisualChild<ContentPresenter>(cbo);
      DataTemplate dTemplate = contentPresenter.ContentTemplate;
      TextBlock textClassLbl = (TextBlock)dTemplate.FindName("tbkClassLabel", contentPresenter);
      if (textClassLbl != null)
      {
        tbkRestrictName.Text = textClassLbl.Text;
      }
    }
  }
}
