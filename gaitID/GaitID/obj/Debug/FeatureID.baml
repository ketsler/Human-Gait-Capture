   M S B A M L   `   `   `  ����A  =GaitID, Version=1.0.0.0, Culture=neutral, PublicKeyToken=nullclr-namespace:GaitIDGaitID  5   	       GaitID.FeatureID   5   	   R NWindowsBase, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35W SPresentationCore, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35\ XPresentationFramework, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35D 9http://schemas.microsoft.com/winfx/2006/xaml/presentation    5   	   R NSystem.Xaml, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089:x,http://schemas.microsoft.com/winfx/2006/xaml     5   	   @d2http://schemas.microsoft.com/expression/blend/2008     5   	   Jmc;http://schemas.openxmlformats.org/markup-compatibility/2006     5   	   &localclr-namespace:GaitID     5   	     � Title$"  Feature-Based Identification��5   	   $	��700��6.   $
��1000��6;    � WindowStartupLocation$ CenterScreen=�6H    � 
ResizeMode$ NoResize=�6m   .��5
      � ���	#FF232323 � RowDefinitions 5   
   �� 5      $
��Auto �6   �� 5      $��* �6   �� 5      $
��Auto �6   .+�5   
   �� -   5         ��Name$ captureNavButton��5      $��Data Capture��6+   $
��Left=�6B   $	��100��6]   $	��190��6j   $	��Top=�6v   $��0��5      ���	#FFCFB87C$��24(�65   $
��Bold"�6C   $��5,0,0,0q�6U   6f   �� 5   
   -   5        $ featureNavButton��5      $��
Feature ID��6+   $
��Left=�6@   $	��100��6[   $	��190��6h   $	��Top=�6t   $��0��5   
   ���	#FFCFB87C$��24(�6.   $
��Bold"�6<   $��	201,0,0,0q�6N   �� 5   
   -   5        $ multivariateNavButton��5      $��Multivariate ID��60   $
��Left=�6J   $	��100��6e   $	��190��6r   $	��Top=�6~   $��0��5   
   ���	#FFCFB87C$��24(�6.   $
��Bold"�6<   $��	396,0,0,0q�6N   �� 5   
   -   5        $ patternNavButton��5      $��
Pattern ID��6+   $
��Left=�6@   $	��100��6[   $	��190��6h   $	��Top=�6t   $��0��5   
   ���	#FFCFB87C$��24(�6.   $
��Bold"�6<   $��	592,0,0,0q�6N   �� 5   
   -   5        $ TestBenchNavButton��5      $��
Test Bench��6-   $
��Left=�6B   $	��100��6]   $	��190��6j   $	��Top=�6v   $��0��5   
   ���	#FFCFB87C$��24(�6.   $
��Bold"�6<   $��	788,0,0,0q�6N   6a   �� 5    
   -   5         ��Name$ FileSelectLabel��5       $'��!Select a file for identification:��6)   $
��Left=�6U   $��	28,10,0,0q�6p   $��1��6�   $	��Top=�6�   
�������$��24(�6�   �� 5!   
   -   5        $ BrowseButton��5!      $��Browse��6'   $��16(�68   $
��Left=�6F   $��	28,55,0,0q�6a   $	��Top=�6t   $��85��6�   $��30��6�   ���	#FF555457
�������$��1��5"   4   $y�Visible=�6A   6V   �� 5#   
   -   5         ��Name$ FileSaveLocationTextBox��5#      $
��Left=�63   $��30��6N   $��
125,55,0,0q�6Z   $��1��6n    �� TextWrapping$ NoWrap=�6{   $	��Top=�5$      $	��219��6*   $��14(�66   $��4q�6D   $y�Visible=�6P    �� 
IsReadOnly . 6e   �� 5%   
   -	   5        $ IdentifyButton��5%      $��Identify��6)   $��16(�6<   $
��Left=�6J   $��
355,55,0,0q�6e   $	��Top=�6y   $��85��6�   $��30��6�   ���	#FF555457
�������$��1��5&   4   $y�Visible=�6A   6V   5(      5)      