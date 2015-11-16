-- *** Dialog ***
create or replace function f_render_dialog (
  p_dynamic_action in apex_plugin.t_dynamic_action,
  p_plugin in apex_plugin.t_plugin )
  return apex_plugin.t_dynamic_action_render_result
as
  -- Application Plugin Attributes
  l_background_color apex_appl_plugins.attribute_01%type := p_plugin.attribute_01;
  l_background_opacitiy apex_appl_plugins.attribute_01%type := p_plugin.attribute_02;

  -- DA Plugin Attributes
  l_modal apex_application_page_items.attribute_01%type := p_dynamic_action.attribute_01; -- y/n
  l_close_on_esc apex_application_page_items.attribute_01%type := p_dynamic_action.attribute_02; -- y/n
  l_title apex_application_page_items.attribute_01%type := p_dynamic_action.attribute_03; -- text
  l_hide_on_load apex_application_page_items.attribute_01%type := upper(p_dynamic_action.attribute_04); -- y/n
  l_on_close_visible_state apex_application_page_items.attribute_01%type := lower(p_dynamic_action.attribute_05); -- prev, show, hide
  l_action apex_application_page_items.attribute_01%type := lower(p_dynamic_action.attribute_06); -- open,close

  -- Return
  l_result apex_plugin.t_dynamic_action_render_result;

  -- Other variables
  l_html varchar2(4000);
  l_affected_elements apex_application_page_da_acts.affected_elements%type;
  l_affected_elements_type apex_application_page_da_acts.affected_elements_type%type;
  l_affected_region_id apex_application_page_da_acts.affected_region_id%type;
  l_affected_region_static_id apex_application_page_regions.static_id%type;

  -- Convert Y/N to True/False (text)
  -- Default to true
  function f_yn_to_true_false_str(p_val in varchar2)
  return varchar2
  as
  begin
    return
      case
        when p_val is null or lower(p_val) != 'n' then 'true'
        else 'false'
      end;
  end f_yn_to_true_false_str;

begin
  -- Debug information (if app is being run in debug mode)
  if apex_application.g_debug then
    apex_plugin_util.debug_dynamic_action (
    p_plugin => p_plugin,
    p_dynamic_action => p_dynamic_action);
  end if;

  -- Cleaup values
  l_modal := f_yn_to_true_false_str(p_val => l_modal);
  l_close_on_esc := f_yn_to_true_false_str(p_val => l_close_on_esc);

  -- If Background color is not null set the CSS
  -- This will only be done once per page
  if l_background_color is not null and l_action != 'close' then
    l_html := q'!
      body .ui-widget-overlay{
       background-image: none ;
       background-color: %BG_COLOR%;
       opacity: %OPACITY%;
      }!';

    l_html := replace(l_html, '%BG_COLOR%', l_background_color);
    l_html := replace(l_html, '%OPACITY%', l_background_opacitiy);

    apex_css.add (
      p_css => l_html,
      p_key => 'ui.oosdialog.background');
  end if;


  -- Hide Affected Elements on Load
  if l_hide_on_load = 'Y' AND l_action != 'close' then
    l_html := '';

    select
      affected_elements,
      lower(affected_elements_type),
      affected_region_id,
      aapr.static_id
    into
      l_affected_elements,
      l_affected_elements_type,
      l_affected_region_id,
      l_affected_region_static_id
    from apex_application_page_da_acts aapda, apex_application_page_regions aapr
    where 1=1
      and aapda.action_id = p_dynamic_action.id
      and aapda.affected_region_id = aapr.region_id(+);

    if l_affected_elements_type = 'jquery selector' then
      l_html := 'apex.jQuery("' || l_affected_elements || '").hide();';
    elsif l_affected_elements_type = 'dom object' then
      l_html := 'apex.jQuery("#' || l_affected_elements || '").hide();';
    elsif l_affected_elements_type = 'region' then
      l_html := 'apex.jQuery("#' || nvl(l_affected_region_static_id, 'R' || l_affected_region_id) || '").hide();';
    else
      -- unknown/unhandled (nothing to hide)
      raise_application_error(-20001, 'Unknown Affected Element Type');
    end if; -- l_affected_elements_type

    apex_javascript.add_onload_code (
      p_code => l_html,
      p_key  => null); -- Leave null so always run
  end if; -- l_hide_on_load

  -- APEX 5.0 #1 Close all open dialogs before submitting page
  apex_javascript.add_onload_code (
    p_code => '$.ui.oosdialog.closeBeforeApexSubmit();',
    p_key => 'ui.oosdialog.onpageload'); -- Only load once.

  -- RETURN
  if l_action = 'open' then
    l_result.javascript_function := '$.ui.oosdialog.daDialog';
    l_result.attribute_01 := l_modal;
    l_result.attribute_02 := l_close_on_esc;
    l_result.attribute_03 := l_title;
    l_result.attribute_04 := l_on_close_visible_state;
  elsif l_action = 'close' THEN
    l_result.javascript_function := '$.ui.oosdialog.daClose';
  else
    raise_application_error(-20001, 'Unknown Action Type');
  end if;

  return l_result;

end f_render_dialog;
