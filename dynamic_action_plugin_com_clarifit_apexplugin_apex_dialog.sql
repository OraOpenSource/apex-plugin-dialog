set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_050000 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2013.01.01'
,p_release=>'5.0.1.00.06'
,p_default_workspace_id=>4101074133915614
,p_default_application_id=>152
,p_default_owner=>'GIFFY'
);
end;
/
prompt --application/ui_types
begin
null;
end;
/
prompt --application/shared_components/plugins/dynamic_action/com_clarifit_apexplugin_apex_dialog
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(5033569935322036150)
,p_plugin_type=>'DYNAMIC ACTION'
,p_name=>'COM.CLARIFIT.APEXPLUGIN.APEX_DIALOG'
,p_display_name=>'OraOpenSource Dialog'
,p_category=>'EFFECT'
,p_supported_ui_types=>'DESKTOP'
,p_javascript_file_urls=>'#PLUGIN_FILES#js/jquery.ui.oosDialog.js'
,p_plsql_code=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'-- *** Dialog ***',
'function f_render_dialog (',
'  p_dynamic_action in apex_plugin.t_dynamic_action,',
'  p_plugin in apex_plugin.t_plugin )',
'  return apex_plugin.t_dynamic_action_render_result',
'as',
'  -- Application Plugin Attributes',
'  l_background_color apex_appl_plugins.attribute_01%type := p_plugin.attribute_01;',
'  l_background_opacitiy apex_appl_plugins.attribute_01%type := p_plugin.attribute_02;',
'',
'  -- DA Plugin Attributes',
'  l_modal apex_application_page_items.attribute_01%type := p_dynamic_action.attribute_01; -- y/n',
'  l_close_on_esc apex_application_page_items.attribute_01%type := p_dynamic_action.attribute_02; -- y/n',
'  l_title apex_application_page_items.attribute_01%type := p_dynamic_action.attribute_03; -- text',
'  l_hide_on_load apex_application_page_items.attribute_01%type := upper(p_dynamic_action.attribute_04); -- y/n',
'  l_on_close_visible_state apex_application_page_items.attribute_01%type := lower(p_dynamic_action.attribute_05); -- prev, show, hide',
'  l_action apex_application_page_items.attribute_01%type := lower(p_dynamic_action.attribute_06); -- open,close',
'',
'  -- Return',
'  l_result apex_plugin.t_dynamic_action_render_result;',
'',
'  -- Other variables',
'  l_html varchar2(4000);',
'  l_affected_elements apex_application_page_da_acts.affected_elements%type;',
'  l_affected_elements_type apex_application_page_da_acts.affected_elements_type%type;',
'  l_affected_region_id apex_application_page_da_acts.affected_region_id%type;',
'  l_affected_region_static_id apex_application_page_regions.static_id%type;',
'',
'  -- Convert Y/N to True/False (text)',
'  -- Default to true',
'  function f_yn_to_true_false_str(p_val in varchar2)',
'  return varchar2',
'  as',
'  begin',
'    return',
'      case',
'        when p_val is null or lower(p_val) != ''n'' then ''true''',
'        else ''false''',
'      end;',
'  end f_yn_to_true_false_str;',
'',
'begin',
'  -- Debug information (if app is being run in debug mode)',
'  if apex_application.g_debug then',
'    apex_plugin_util.debug_dynamic_action (',
'    p_plugin => p_plugin,',
'    p_dynamic_action => p_dynamic_action);',
'  end if;',
'',
'  -- Cleaup values',
'  l_modal := f_yn_to_true_false_str(p_val => l_modal);',
'  l_close_on_esc := f_yn_to_true_false_str(p_val => l_close_on_esc);',
'',
'  -- If Background color is not null set the CSS',
'  -- This will only be done once per page',
'  if l_background_color is not null and l_action != ''close'' then',
'    l_html := q''!',
'      body .ui-widget-overlay{',
'       background-image: none ;',
'       background-color: %BG_COLOR%;',
'       opacity: %OPACITY%;',
'      }!'';',
'',
'    l_html := replace(l_html, ''%BG_COLOR%'', l_background_color);',
'    l_html := replace(l_html, ''%OPACITY%'', l_background_opacitiy);',
'',
'    apex_css.add (',
'      p_css => l_html,',
'      p_key => ''ui.oosdialog.background'');',
'  end if;',
'',
'',
'  -- Hide Affected Elements on Load',
'  if l_hide_on_load = ''Y'' AND l_action != ''close'' then',
'    l_html := '''';',
'',
'    select',
'      affected_elements,',
'      lower(affected_elements_type),',
'      affected_region_id,',
'      aapr.static_id',
'    into',
'      l_affected_elements,',
'      l_affected_elements_type,',
'      l_affected_region_id,',
'      l_affected_region_static_id',
'    from apex_application_page_da_acts aapda, apex_application_page_regions aapr',
'    where 1=1',
'      and aapda.action_id = p_dynamic_action.id',
'      and aapda.affected_region_id = aapr.region_id(+);',
'',
'    if l_affected_elements_type = ''jquery selector'' then',
'      l_html := ''apex.jQuery("'' || l_affected_elements || ''").hide();'';',
'    elsif l_affected_elements_type = ''dom object'' then',
'      l_html := ''apex.jQuery("#'' || l_affected_elements || ''").hide();'';',
'    elsif l_affected_elements_type = ''region'' then',
'      l_html := ''apex.jQuery("#'' || nvl(l_affected_region_static_id, ''R'' || l_affected_region_id) || ''").hide();'';',
'    else',
'      -- unknown/unhandled (nothing to hide)',
'      raise_application_error(-20001, ''Unknown Affected Element Type'');',
'    end if; -- l_affected_elements_type',
'',
'    apex_javascript.add_onload_code (',
'      p_code => l_html,',
'      p_key  => null); -- Leave null so always run',
'  end if; -- l_hide_on_load',
'',
'  -- APEX 5.0 #1 Close all open dialogs before submitting page',
'  apex_javascript.add_onload_code (',
'    p_code => ''$.ui.oosdialog.closeBeforeApexSubmit();'',',
'    p_key => ''ui.oosdialog.onpageload''); -- Only load once.',
'',
'  -- RETURN',
'  if l_action = ''open'' then',
'    l_result.javascript_function := ''$.ui.oosdialog.daDialog'';',
'    l_result.attribute_01 := l_modal;',
'    l_result.attribute_02 := l_close_on_esc;',
'    l_result.attribute_03 := l_title;',
'    l_result.attribute_04 := l_on_close_visible_state;',
'  elsif l_action = ''close'' THEN',
'    l_result.javascript_function := ''$.ui.oosdialog.daClose'';',
'  else',
'    raise_application_error(-20001, ''Unknown Action Type'');',
'  end if;',
'',
'  return l_result;',
'',
'end f_render_dialog;',
''))
,p_render_function=>'f_render_dialog'
,p_standard_attributes=>'REGION:JQUERY_SELECTOR:JAVASCRIPT_EXPRESSION:REQUIRED'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'<p>',
'	<strong>ClariFit Dialog</strong></p>',
'<div>',
'	Plug-in Type: Dynamic Action</div>',
'<div>',
'	Summary: Creates dialog and modal windows.</div>',
'<div>',
'	&nbsp;</div>',
'<div>',
'	<em><strong>Depends:</strong></em></div>',
'<div>',
'	&nbsp;$.console.js &nbsp;- http://code.google.com/p/js-console-wrapper/</div>',
'<div>',
'	&nbsp;</div>',
'<div>',
'	<em><strong>Contact information</strong></em></div>',
'<div>',
'	Developed by ClariFit Inc.</div>',
'<div>',
'	http://www.clarifit.com</div>',
'<div>',
'	apex@clarifit.com</div>',
'<div>',
'	&nbsp;</div>',
'<div>',
'	<em><strong>License</strong></em></div>',
'<div>',
'	Licensed Under: GNU General Public License, version 3 (GPL-3.0) - http://www.opensource.org/licenses/gpl-3.0.html</div>',
'<div>',
'	&nbsp;</div>',
'<div>',
'	<strong><em>About</em></strong></div>',
'<div>',
'	This plugin was highlighted in the book: Expert Oracle Application Express Plugins&nbsp;<a href="http://goo.gl/089zi">http://goo.gl/089zi</a></div>',
'<div>',
'	&nbsp;</div>',
'<div>',
'	<em><strong>Info</strong></em></div>',
'<div>',
'	To use this plugin, create a dynamic action and select the ClariFit Dialog plugin. The main attribute is the Action attribute. Setting this will determine to open or close the dialog/modal window. All the attributes contain help text explaining how '
||'they&#39;re used.</div>'))
,p_version_identifier=>'3.0.0'
,p_about_url=>'http://oraopensource.com'
,p_files_version=>10
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(5485276543024947336)
,p_plugin_id=>wwv_flow_api.id(5033569935322036150)
,p_attribute_scope=>'APPLICATION'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Background Color'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_display_length=>10
,p_is_translatable=>false
,p_help_text=>'Default background color for modal windows. Enter a CSS qualified color (i.e. either color name or #<span style="font-style:italic;">hex</span> value. If no color is specified then the jQuery UI theme default will be used.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(5486330328310980987)
,p_plugin_id=>wwv_flow_api.id(5033569935322036150)
,p_attribute_scope=>'APPLICATION'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Background Opacity'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_default_value=>'0.3'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'Select the opacity of background color for modal windows.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(5486716454761998038)
,p_plugin_attribute_id=>wwv_flow_api.id(5486330328310980987)
,p_display_sequence=>10
,p_display_value=>'10%'
,p_return_value=>'0.1'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(5486772237577002588)
,p_plugin_attribute_id=>wwv_flow_api.id(5486330328310980987)
,p_display_sequence=>20
,p_display_value=>'20%'
,p_return_value=>'0.2'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(5486811541733003770)
,p_plugin_attribute_id=>wwv_flow_api.id(5486330328310980987)
,p_display_sequence=>30
,p_display_value=>'30%'
,p_return_value=>'0.3'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(5486823644504004551)
,p_plugin_attribute_id=>wwv_flow_api.id(5486330328310980987)
,p_display_sequence=>40
,p_display_value=>'40%'
,p_return_value=>'0.4'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(5486868248659005772)
,p_plugin_attribute_id=>wwv_flow_api.id(5486330328310980987)
,p_display_sequence=>50
,p_display_value=>'50%'
,p_return_value=>'0.5'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(5486924554200007340)
,p_plugin_attribute_id=>wwv_flow_api.id(5486330328310980987)
,p_display_sequence=>60
,p_display_value=>'60%'
,p_return_value=>'0.6'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(5486945756971008141)
,p_plugin_attribute_id=>wwv_flow_api.id(5486330328310980987)
,p_display_sequence=>70
,p_display_value=>'70%'
,p_return_value=>'0.7'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(5486957826627008824)
,p_plugin_attribute_id=>wwv_flow_api.id(5486330328310980987)
,p_display_sequence=>80
,p_display_value=>'80%'
,p_return_value=>'0.8'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(5486976929397009673)
,p_plugin_attribute_id=>wwv_flow_api.id(5486330328310980987)
,p_display_sequence=>90
,p_display_value=>'90%'
,p_return_value=>'0.9'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(5487001032514010580)
,p_plugin_attribute_id=>wwv_flow_api.id(5486330328310980987)
,p_display_sequence=>100
,p_display_value=>'100%'
,p_return_value=>'1'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(5487417949614025020)
,p_plugin_id=>wwv_flow_api.id(5033569935322036150)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Modal'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(76942390883007269)
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'open'
,p_help_text=>'Modal window or dialog window.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(5487980830614047855)
,p_plugin_id=>wwv_flow_api.id(5033569935322036150)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Close on Escape'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(76942390883007269)
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'open'
,p_help_text=>'If set to yes, user can hit the <span style="font-style:italic;">esc</span> key to close the window.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(5488712741742079421)
,p_plugin_id=>wwv_flow_api.id(5033569935322036150)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Dialog Title'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>true
,p_depending_on_attribute_id=>wwv_flow_api.id(76942390883007269)
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'open'
,p_help_text=>'Title to appear at the top of the dialog/modal window. If the region already contains a title may want to leave this empty.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(5490624650887167233)
,p_plugin_id=>wwv_flow_api.id(5033569935322036150)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'Hide Affected Elements on Page Load'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(76942390883007269)
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'open'
,p_help_text=>'If set to yes, the contents for the modal/dialog window will be hidden once the page is loaded. For example suppose you have "License Agreement" region which you only want to be displayed when the user clicks on a button. If you set this option to Ye'
||'s then when the page is loaded the plug-in will automatically hide the "License Agreement" region for you. This saves you the hassle of having to worry about using different region templates to show/hide the region by default.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(5513342555041218638)
,p_plugin_id=>wwv_flow_api.id(5033569935322036150)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_prompt=>'On Close Visible State'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'prev'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(76942390883007269)
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'open'
,p_lov_type=>'STATIC'
,p_help_text=>'Define what visibility status to set once the modal window closes. In most cases you will probably want to leave it to the default value (Previous state). '
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(5513371835086222301)
,p_plugin_attribute_id=>wwv_flow_api.id(5513342555041218638)
,p_display_sequence=>10
,p_display_value=>'Previous (default)'
,p_return_value=>'prev'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(5513397446168225543)
,p_plugin_attribute_id=>wwv_flow_api.id(5513342555041218638)
,p_display_sequence=>20
,p_display_value=>'Show'
,p_return_value=>'show'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(5513437828291229785)
,p_plugin_attribute_id=>wwv_flow_api.id(5513342555041218638)
,p_display_sequence=>30
,p_display_value=>'Hide'
,p_return_value=>'hide'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(76942390883007269)
,p_plugin_id=>wwv_flow_api.id(5033569935322036150)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>1
,p_prompt=>'Action'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'open'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'Open or Close the dialog window.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(76946992961007874)
,p_plugin_attribute_id=>wwv_flow_api.id(76942390883007269)
,p_display_sequence=>10
,p_display_value=>'Open'
,p_return_value=>'open'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(76951294692008385)
,p_plugin_attribute_id=>wwv_flow_api.id(76942390883007269)
,p_display_sequence=>20
,p_display_value=>'Close'
,p_return_value=>'close'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(78860287917457633)
,p_plugin_id=>wwv_flow_api.id(5033569935322036150)
,p_name=>'cfpluginapexdialogbeforeclose'
,p_display_name=>'Before Close'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(78868712159464647)
,p_plugin_id=>wwv_flow_api.id(5033569935322036150)
,p_name=>'cfpluginapexdialogclose'
,p_display_name=>'After Close'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(78864492073458787)
,p_plugin_id=>wwv_flow_api.id(5033569935322036150)
,p_name=>'cfpluginapexdialogcreate'
,p_display_name=>'Dialog Open'
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A2A0A202A204F72614F70656E536F75726365206A5175657279205549204469616C6F670A202A20506C75672D696E20547970653A204479616E6D696320416374696F6E0A202A2053756D6D6172793A20446973706C6179732061206A517565726920';
wwv_flow_api.g_varchar2_table(2) := '5549204469616C6F672077696E646F7720666F7220616666656374656420656C656D656E74730A202A0A202A20446570656E64733A0A202A20206A71756572792E75692E6469616C6F672E6A730A202A0A202A204E6F7465733A0A202A204F626A656374';
wwv_flow_api.g_varchar2_table(3) := '20746F2062652073686F776E20696E204469616C6F672077696E646F77206E6565647320746F206265207772617070656420696E206F7264657220746F2070726573657276652069747320706F736974696F6E20696E20444F4D0A202A205365653A2068';
wwv_flow_api.g_varchar2_table(4) := '7474703A2F2F666F72756D732E6F7261636C652E636F6D2F666F72756D732F7468726561642E6A7370613F6D65737361676549443D3331383035333220666F72206D6F726520696E666F726D6174696F6E2E0A202A0A202A204368616E6765733A0A202A';
wwv_flow_api.g_varchar2_table(5) := '20312E302E310A202A20202D204164646564206164646974696F6E616C20646562756720696E666F726D6174696F6E20696E2074686520636C6F73652066756E6374696F6E0A202A20202D20416464656420737570706F727420666F72206578706C6963';
wwv_flow_api.g_varchar2_table(6) := '7420636C6F73652066756E6374696F6E0A202A20332E302E300A202A20202D20506F72742066726F6D20436C61726946697420746F204F72614F70656E536F757263650A202A20202D204150455820352E302E3020537570706F727420286A5175657279';
wwv_flow_api.g_varchar2_table(7) := '20554920312E3130290A202A202020202D204D616A6F72206368616E67652069732074686174206E6577206A517565727920554920617474616368657320746F20444F4D20616E642063616E277420757365207772617070657220636F6E636570742E0A';
wwv_flow_api.g_varchar2_table(8) := '202A0A202A205E5E5E20436F6E7461637420696E666F726D6174696F6E205E5E5E0A202A20446576656C6F706564206279204F72614F70656E536F757263650A202A20687474703A2F2F6F72616F70656E736F757263652E636F6D0A202A206D61727469';
wwv_flow_api.g_varchar2_table(9) := '6E40636C6172696669742E636F6D0A202A0A202A205E5E5E204C6963656E7365205E5E5E0A202A204C6963656E73656420556E6465723A204D4954202D20687474703A2F2F63686F6F7365616C6963656E73652E636F6D2F6C6963656E7365732F6D6974';
wwv_flow_api.g_varchar2_table(10) := '2F0A202A0A202A2040617574686F72204D617274696E204769666679204427536F757A61202D20687474703A2F2F7777772E74616C6B617065782E636F6D0A202A2F0A2866756E6374696F6E2824297B0A0A2020766172206F6F734469616C6F67203D20';
wwv_flow_api.g_varchar2_table(11) := '7B0A20202020636C6173734E616D65203A20276F6F732D6469616C6F67270A20207D3B0A0A2020242E776964676574282775692E6F6F736469616C6F67272C207B0A202020202F2F2064656661756C74206F7074696F6E730A202020206F7074696F6E73';
wwv_flow_api.g_varchar2_table(12) := '3A207B0A2020202020202F2F436F6E666967757261626C65206F7074696F6E7320696E204150455820706C7567696E0A2020202020206D6F64616C3A20747275652C0A202020202020636C6F73654F6E4573636170653A20747275652C0A202020202020';
wwv_flow_api.g_varchar2_table(13) := '7469746C653A2027272C0A202020202020706572736973743A20747275652C202F2F467574757265206F7074696F6E2C206E6F20616666656374207269676874206E6F770A2020202020206F6E436C6F736556697369626C6553746174653A2027707265';
wwv_flow_api.g_varchar2_table(14) := '7627202F2F526573746F7265206F626A656374732076697369626C65207374617465206F6E636520636C6F7365640A202020207D2C0A0A202020202F2A2A0A20202020202A20496E69742066756E6374696F6E2E20546869732066756E6374696F6E2077';
wwv_flow_api.g_varchar2_table(15) := '696C6C2062652063616C6C656420656163682074696D652074686520776964676574206973207265666572656E6365642077697468206E6F20706172616D65746572730A20202020202A2F0A202020205F696E69743A2066756E6374696F6E28297B0A20';
wwv_flow_api.g_varchar2_table(16) := '202020202076617220756977203D20746869733B0A20202020202076617220636F6E736F6C6547726F75704E616D65203D207569772E5F73636F7065202B20272E5F696E6974273B0A2020202020202F2F20617065782E64656275672E67726F7570436F';
wwv_flow_api.g_varchar2_table(17) := '6C6C617073656428636F6E736F6C6547726F75704E616D65293B0A0A2020202020202F2F46696E6420746865206F626A656374732076697369626C65207374617465206265666F7265206D616B696E67206469616C6F672077696E646F77202875736564';
wwv_flow_api.g_varchar2_table(18) := '20746F20726573746F7265206966206E6563657373617279290A2020202020207569772E5F76616C7565732E6265666F726553686F7756697369626C65203D207569772E5F656C656D656E74732E24656C656D656E742E697328273A76697369626C6527';
wwv_flow_api.g_varchar2_table(19) := '293B0A202020202020617065782E64656275672E6C6F6728276265666F726553686F7756697369626C653A20272C207569772E5F76616C7565732E6265666F726553686F7756697369626C65293B0A0A2020202020202F2F437265617465204469616C6F';
wwv_flow_api.g_varchar2_table(20) := '672077696E646F770A2020202020202F2F4372656174696E6720656163682074696D6520736F20746861742077652063616E20656173696C7920726573746F7265206974732076697369626C65207374617465206966206E65636573736172790A202020';
wwv_flow_api.g_varchar2_table(21) := '2020207569772E5F656C656D656E74732E24656C656D656E742E6469616C6F67287B0A20202020202020202F2F20617070656E64546F3A204E6F74653A206966206368616E676520746869732C206E65656420746F206D6F646966792074686520435353';
wwv_flow_api.g_varchar2_table(22) := '2073657474696E677320696E20665F72656E6465725F6469616C6F670A20202020202020206D6F64616C3A207569772E6F7074696F6E732E6D6F64616C2C0A2020202020202020636C6F73654F6E4573636170653A207569772E6F7074696F6E732E636C';
wwv_flow_api.g_varchar2_table(23) := '6F73654F6E4573636170652C0A20202020202020207469746C653A207569772E6F7074696F6E732E7469746C652C0A20202020202020202F2F4F7074696F6E732062656C6F772043616E206265206D61646520636F6E666967757261626C652069662072';
wwv_flow_api.g_varchar2_table(24) := '657175697265640A202020202020202077696474683A20276175746F272C0A20202020202020202F2F4576656E742042696E64696E670A20202020202020206265666F7265436C6F73653A2066756E6374696F6E286576656E742C20756929207B0A2020';
wwv_flow_api.g_varchar2_table(25) := '20202020202020202F2F20444F204E4F54206368616E6765206576656E742070726566697820746F20226F6F732220746F20656E61626C65206261636B776172647320636F6D7061746962696C6974790A20202020202020202020242874686973292E74';
wwv_flow_api.g_varchar2_table(26) := '72696767657228276366706C7567696E617065786469616C6F676265666F7265636C6F7365272C207B6576656E743A206576656E742C2075693A2075697D293B207D2C0A2020202020202020636C6F73653A2066756E6374696F6E286576656E742C2075';
wwv_flow_api.g_varchar2_table(27) := '6929207B207569772E636C6F7365286576656E742C207569293B207D2C0A20202020202020206372656174653A2066756E6374696F6E286576656E742C20756929207B0A20202020202020202020242874686973292E7472696767657228276366706C75';
wwv_flow_api.g_varchar2_table(28) := '67696E617065786469616C6F67637265617465272C207B6576656E743A206576656E742C2075693A2075697D293B207D0A2020202020207D293B0A0A2020202020202F2F4164642066697865642061747472696275746520286F74686572776973652074';
wwv_flow_api.g_varchar2_table(29) := '6865206469616C6F67207363726F6C6C732077697468207468652070616765290A2020202020207569772E5F656C656D656E74732E24656C656D656E742E706172656E7428272E75692D6469616C6F6727292E637373287B706F736974696F6E3A226669';
wwv_flow_api.g_varchar2_table(30) := '786564227D293B0A0A2020202020202F2F20617065782E64656275672E67726F7570456E6428636F6E736F6C6547726F75704E616D65293B0A202020207D2C202F2F5F696E69740A0A202020202F2A2A0A20202020202A20536574207072697661746520';
wwv_flow_api.g_varchar2_table(31) := '7769646765742076617261626C65730A20202020202A2F0A202020205F736574576964676574566172733A2066756E6374696F6E28297B0A20202020202076617220756977203D20746869733B0A0A2020202020207569772E5F73636F7065203D202775';
wwv_flow_api.g_varchar2_table(32) := '692E27202B207569772E7769646765744E616D653B202F2F466F7220646562756767696E670A0A2020202020207569772E5F76616C756573203D207B0A20202020202020206265666F726553686F7756697369626C653A2066616C7365202F2F56697369';
wwv_flow_api.g_varchar2_table(33) := '626C65207374617465206265666F72652073686F770A2020202020207D3B0A0A2020202020207569772E5F656C656D656E7473203D207B0A202020202020202024656C656D656E74203A2024287569772E656C656D656E745B305D29202F2F4166666563';
wwv_flow_api.g_varchar2_table(34) := '74656420656C656D656E740A2020202020207D3B0A0A202020207D2C202F2F5F736574576964676574566172730A0A202020202F2A2A0A20202020202A204372656174652066756E6374696F6E3A2043616C6C6564207468652066697273742074696D65';
wwv_flow_api.g_varchar2_table(35) := '20776964676574206973206173736F63696174656420746F20746865206F626A6563740A20202020202A20446F657320616C6C207468652072657175697265642073657475702065746320616E642062696E6473206368616E6765206576656E740A2020';
wwv_flow_api.g_varchar2_table(36) := '2020202A2F0A202020205F6372656174653A2066756E6374696F6E28297B0A20202020202076617220756977203D20746869733B0A0A2020202020207569772E5F7365745769646765745661727328293B0A0A20202020202076617220636F6E736F6C65';
wwv_flow_api.g_varchar2_table(37) := '47726F75704E616D65203D207569772E5F73636F7065202B20272E5F637265617465273B0A2020202020202F2F20617065782E64656275672E67726F7570436F6C6C617073656428636F6E736F6C6547726F75704E616D65293B0A202020202020617065';
wwv_flow_api.g_varchar2_table(38) := '782E64656275672E6C6F672827746869733A272C20756977293B0A202020202020617065782E64656275672E6C6F672827656C656D656E743A272C207569772E656C656D656E745B305D293B0A0A2020202020202F2F204E65656420746F206164642074';
wwv_flow_api.g_varchar2_table(39) := '68697320736F2063616E20656173696C7920636C6F736520616E79206F70656E206469616C6F6773206265666F7265207375626D697474696E6720706167650A2020202020207569772E5F656C656D656E74732E24656C656D656E742E616464436C6173';
wwv_flow_api.g_varchar2_table(40) := '73286F6F734469616C6F672E636C6173734E616D65293B0A0A2020202020202F2F20617065782E64656275672E67726F7570456E6428636F6E736F6C6547726F75704E616D65293B0A202020207D2C2F2F5F6372656174650A0A202020202F2A2A0A2020';
wwv_flow_api.g_varchar2_table(41) := '2020202A2052656D6F76657320616C6C2066756E6374696F6E616C697479206173736F636961746564207769746820746865206F6F736469616C6F670A20202020202A2057696C6C2072656D6F766520746865206368616E6765206576656E7420617320';
wwv_flow_api.g_varchar2_table(42) := '77656C6C0A20202020202A204F6464732061726520746869732077696C6C206E6F742062652063616C6C65642066726F6D20415045582E0A20202020202A2F0A2020202064657374726F793A2066756E6374696F6E2829207B0A20202020202076617220';
wwv_flow_api.g_varchar2_table(43) := '756977203D20746869733B0A0A202020202020617065782E64656275672E6C6F67287569772E5F73636F70652C202764657374726F79272C20756977293B0A202020202020242E5769646765742E70726F746F747970652E64657374726F792E6170706C';
wwv_flow_api.g_varchar2_table(44) := '79287569772C20617267756D656E7473293B202F2F2064656661756C742064657374726F790A2020202020202F2F20756E7265676973746572206469616C6F670A2020202020207569772E5F656C656D656E74732E24656C656D656E742E6469616C6F67';
wwv_flow_api.g_varchar2_table(45) := '282764657374726F7927290A202020207D2C2F2F64657374726F790A0A202020202F2A2A0A20202020202A20436C6F73657320746865206469616C6F672077696E646F770A20202020202A2040706172616D206576656E740A20202020202A204075690A';
wwv_flow_api.g_varchar2_table(46) := '20202020202A2F0A20202020636C6F73653A2066756E6374696F6E286576656E742C207569297B0A20202020202076617220756977203D20746869733B0A20202020202076617220636F6E736F6C6547726F75704E616D65203D207569772E5F73636F70';
wwv_flow_api.g_varchar2_table(47) := '65202B20272E636C6F7365273B0A2020202020202F2F20617065782E64656275672E67726F7570436F6C6C617073656428636F6E736F6C6547726F75704E616D65293B0A2020202020202F2F20617065782E64656275672E6C6F67506172616D7328293B';
wwv_flow_api.g_varchar2_table(48) := '0A202020202020617065782E64656275672E6C6F6728277569773A20272C20756977293B0A0A2020202020202F2F44657374726F7920746865206A517565727920554920656C656D656E747320736F207468617420697420646973706C61797320617320';
wwv_flow_api.g_varchar2_table(49) := '6966206469616C6F6720686164206E6F74206265656E206170706C6965640A2020202020207569772E5F656C656D656E74732E24656C656D656E742E6469616C6F6728202264657374726F792220293B0A0A2020202020202F2F53686F77206F6E6C7920';
wwv_flow_api.g_varchar2_table(50) := '69662070726576696F7573207374617465207761732073686F770A20202020202069662028287569772E5F76616C7565732E6265666F726553686F7756697369626C65202626207569772E6F7074696F6E732E6F6E436C6F736556697369626C65537461';
wwv_flow_api.g_varchar2_table(51) := '7465203D3D2027707265762729207C7C207569772E6F7074696F6E732E6F6E436C6F736556697369626C655374617465203D3D202773686F7727297B0A20202020202020207569772E5F656C656D656E74732E24656C656D656E742E73686F7728293B0A';
wwv_flow_api.g_varchar2_table(52) := '2020202020207D0A202020202020656C7365207B0A20202020202020207569772E5F656C656D656E74732E24656C656D656E742E6869646528293B0A2020202020207D0A0A2020202020202F2F5472696767657220637573746F6D204150455820457665';
wwv_flow_api.g_varchar2_table(53) := '6E740A2020202020207569772E5F656C656D656E74732E24656C656D656E742E7472696767657228276366706C7567696E617065786469616C6F67636C6F7365272C207B6576656E743A206576656E742C2075693A2075697D293B0A0A2020202020202F';
wwv_flow_api.g_varchar2_table(54) := '2F20617065782E64656275672E67726F7570456E6428636F6E736F6C6547726F75704E616D65293B0A202020207D2F2F636C6F73650A0A20207D293B202F2F75692E6F6F736469616C6F670A0A2020242E657874656E6428242E75692E6F6F736469616C';
wwv_flow_api.g_varchar2_table(55) := '6F672C207B0A202020202F2A2A0A20202020202A2046756E6374696F6E20746F2062652063616C6C65642066726F6D2074686520415045582044796E616D696320416374696F6E2070726F636573730A20202020202A204E6F2076616C75657320617265';
wwv_flow_api.g_varchar2_table(56) := '2070617373656420696E0A20202020202A2022746869732220697320746865204150455820444120227468697322206F626A6563740A20202020202A2F0A2020202064614469616C6F673A2066756E6374696F6E28297B0A202020202020766172207363';
wwv_flow_api.g_varchar2_table(57) := '6F7065203D2027242E75692E6F6F736469616C6F672E64614469616C6F67273B0A20202020202076617220646154686973203D20746869733B202F2F4E6F746520746861742022746869732220726570726573656E74732074686520415045582044796E';
wwv_flow_api.g_varchar2_table(58) := '616D696320416374696F6E206F626A6563740A2020202020202F2F20617065782E64656275672E67726F7570436F6C6C61707365642873636F7065293B0A202020202020617065782E64656275672E6C6F6728274150455820444120746869733A202720';
wwv_flow_api.g_varchar2_table(59) := '2C20646154686973293B0A0A2020202020202F2F536574206F7074696F6E730A202020202020766172206F7074696F6E73203D207B0A20202020202020206D6F64616C3A206461546869732E616374696F6E2E6174747269627574653031203D3D3D2027';
wwv_flow_api.g_varchar2_table(60) := '66616C736527203F2066616C7365203A20747275652C0A2020202020202020636C6F73654F6E4573636170653A206461546869732E616374696F6E2E6174747269627574653032203D3D3D202766616C736527203F2066616C7365203A20747275652C0A';
wwv_flow_api.g_varchar2_table(61) := '20202020202020207469746C653A206461546869732E616374696F6E2E61747472696275746530332C0A20202020202020206F6E436C6F736556697369626C6553746174653A206461546869732E616374696F6E2E61747472696275746530340A202020';
wwv_flow_api.g_varchar2_table(62) := '2020207D3B0A0A202020202020666F72287661722069203D20302C20656E64203D206461546869732E6166666563746564456C656D656E74732E6C656E6774683B2069203C20656E643B20692B2B297B0A2020202020202020617065782E64656275672E';
wwv_flow_api.g_varchar2_table(63) := '6C6F6728274469616C6F67696E673A20272C206461546869732E6166666563746564456C656D656E74735B695D293B0A202020202020202024286461546869732E6166666563746564456C656D656E74735B695D292E6F6F736469616C6F67286F707469';
wwv_flow_api.g_varchar2_table(64) := '6F6E73293B0A2020202020207D2F2F666F720A0A2020202020202F2F20617065782E64656275672E67726F7570456E642873636F7065293B0A202020207D2C2F2F64614469616C6F670A0A202020202F2A2A0A20202020202A20436C6F7365206469616C';
wwv_flow_api.g_varchar2_table(65) := '6F672077696E646F772873290A20202020202A204E6F2076616C756573206172652070617373656420696E0A20202020202A2022746869732220697320746865204150455820444120227468697322206F626A6563740A20202020202A2F0A2020202064';
wwv_flow_api.g_varchar2_table(66) := '61436C6F73653A2066756E6374696F6E28297B0A2020202020207661722073636F7065203D2027242E75692E6F6F736469616C6F672E6461436C6F7365273B0A20202020202076617220646154686973203D20746869733B202F2F4E6F74652074686174';
wwv_flow_api.g_varchar2_table(67) := '2022746869732220726570726573656E74732074686520415045582044796E616D696320416374696F6E206F626A6563740A2020202020202F2F20617065782E64656275672E67726F7570436F6C6C61707365642873636F7065293B0A20202020202061';
wwv_flow_api.g_varchar2_table(68) := '7065782E64656275672E6C6F6728274150455820444120746869733A2027202C20646154686973293B0A0A202020202020666F72287661722069203D20302C20656E64203D206461546869732E6166666563746564456C656D656E74732E6C656E677468';
wwv_flow_api.g_varchar2_table(69) := '3B2069203C20656E643B20692B2B297B0A2020202020202020617065782E64656275672E6C6F672827436C6F73696E673A20272C206461546869732E6166666563746564456C656D656E74735B695D293B0A202020202020202024286461546869732E61';
wwv_flow_api.g_varchar2_table(70) := '66666563746564456C656D656E74735B695D292E6F6F736469616C6F672827636C6F736527293B0A2020202020207D2F2F666F720A0A2020202020202F2F20617065782E64656275672E67726F7570456E642873636F7065293B0A202020207D2C2F2F64';
wwv_flow_api.g_varchar2_table(71) := '61436C6F73650A0A202020202F2A2A0A20202020202A2048616E646C65732074686520617065782E7375626D69742070726F636573732028736565204973737565202331290A20202020202A204E65656420746F20646F207468697320666F7220415045';
wwv_flow_api.g_varchar2_table(72) := '5820352E30206173206A517565727920554920312E3130206170706C69657320746865206469616C6F6720746F2074686520444F4D0A20202020202A20436C6F736520616C6C20746865206469616C6F67730A20202020202A204F6E6C792072756E2074';
wwv_flow_api.g_varchar2_table(73) := '686973206F6E63650A20202020202A2F0A20202020636C6F73654265666F7265417065785375626D69743A2066756E6374696F6E28297B0A2020202020202428617065782E6750616765436F6E7465787424292E6F6E282261706578706167657375626D';
wwv_flow_api.g_varchar2_table(74) := '69742E6F6F736469616C6F67222C2066756E6374696F6E2829207B0A2020202020202020617065782E64656275672E6C6F67282761706578706167657375626D69742E6F6F736469616C6F673A20436C6F73696E67206F70656E206469616C6F67732729';
wwv_flow_api.g_varchar2_table(75) := '3B0A0A20202020202020202428272E27202B206F6F734469616C6F672E636C6173734E616D65292E656163682866756E6374696F6E2869297B0A20202020202020202020766172202474686973203D20242874686973293B0A0A20202020202020202020';
wwv_flow_api.g_varchar2_table(76) := '2F2F20546865206164646974696F6E616C2024746869732E64617461282775692D6469616C6F6727292069732072657175697265642073696E63652064657374726F792063616C6C2061626F76652072656D6F76657320746869730A2020202020202020';
wwv_flow_api.g_varchar2_table(77) := '20206966202824746869732E64617461282775692D6F6F736469616C6F6727292026262024746869732E64617461282775692D6469616C6F6727292026262024746869732E6469616C6F67282769734F70656E2729297B0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(78) := '617065782E64656275672E6C6F672827436C6F73696E673A272C202474686973293B0A20202020202020202020202024746869732E6F6F736469616C6F672827636C6F736527293B0A202020202020202020207D2F2F69660A0A20202020202020207D29';
wwv_flow_api.g_varchar2_table(79) := '3B2F2F2428272E6F6F732D6469616C6F6727290A2020202020207D293B2F2F2428617065782E6750616765436F6E7465787424290A202020207D2F2F636C6F73654265666F7265417065785375626D69740A0A20207D293B2F2F457874656E640A0A7D29';
wwv_flow_api.g_varchar2_table(80) := '28617065782E6A5175657279293B0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(63622586926798059)
,p_plugin_id=>wwv_flow_api.id(5033569935322036150)
,p_file_name=>'js/jquery.ui.oosDialog.js'
,p_mime_type=>'application/x-javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false), p_is_component_import => true);
commit;
end;
/
set verify on feedback on define on
prompt  ...done
