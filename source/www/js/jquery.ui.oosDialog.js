/**
 * OraOpenSource jQuery UI Dialog
 * Plug-in Type: Dyanmic Action
 * Summary: Displays a jQueri UI Dialog window for affected elements
 *
 * Depends:
 *  jquery.ui.dialog.js
 *
 * Notes:
 * Object to be shown in Dialog window needs to be wrapped in order to preserve its position in DOM
 * See: http://forums.oracle.com/forums/thread.jspa?messageID=3180532 for more information.
 *
 * Changes:
 * 1.0.1
 *  - Added additional debug information in the close function
 *  - Added support for explict close function
 * 3.0.0
 *  - Port from ClariFit to OraOpenSource
 *  - APEX 5.0.0 Support (jQuery UI 1.10)
 *    - Major change is that new jQuery UI attaches to DOM and can't use wrapper concept.
 *
 * ^^^ Contact information ^^^
 * Developed by OraOpenSource
 * http://oraopensource.com
 * martin@clarifit.com
 *
 * ^^^ License ^^^
 * Licensed Under: MIT - http://choosealicense.com/licenses/mit/
 *
 * @author Martin Giffy D'Souza - http://www.talkapex.com
 */
(function($){

  var oosDialog = {
    className : 'oos-dialog'
  };

  $.widget('ui.oosdialog', {
    // default options
    options: {
      //Configurable options in APEX plugin
      modal: true,
      closeOnEscape: true,
      title: '',
      persist: true, //Future option, no affect right now
      onCloseVisibleState: 'prev' //Restore objects visible state once closed
    },

    /**
     * Init function. This function will be called each time the widget is referenced with no parameters
     */
    _init: function(){
      var uiw = this;
      var consoleGroupName = uiw._scope + '._init';
      // apex.debug.groupCollapsed(consoleGroupName);

      //Find the objects visible state before making dialog window (used to restore if necessary)
      uiw._values.beforeShowVisible = uiw._elements.$element.is(':visible');
      apex.debug.log('beforeShowVisible: ', uiw._values.beforeShowVisible);

      //Create Dialog window
      //Creating each time so that we can easily restore its visible state if necessary
      uiw._elements.$element.dialog({
        // appendTo: Note: if change this, need to modify the CSS settings in f_render_dialog
        modal: uiw.options.modal,
        closeOnEscape: uiw.options.closeOnEscape,
        title: uiw.options.title,
        //Options below Can be made configurable if required
        width: 'auto',
        //Event Binding
        beforeClose: function(event, ui) {
          // DO NOT change event prefix to "oos" to enable backwards compatibility
          $(this).trigger('cfpluginapexdialogbeforeclose', {event: event, ui: ui}); },
        close: function(event, ui) { uiw.close(event, ui); },
        create: function(event, ui) {
          $(this).trigger('cfpluginapexdialogcreate', {event: event, ui: ui}); }
      });

      //Add fixed attribute (otherwise the dialog scrolls with the page)
      uiw._elements.$element.parent('.ui-dialog').css({position:"fixed"});

      // apex.debug.groupEnd(consoleGroupName);
    }, //_init

    /**
     * Set private widget varables
     */
    _setWidgetVars: function(){
      var uiw = this;

      uiw._scope = 'ui.' + uiw.widgetName; //For debugging

      uiw._values = {
        beforeShowVisible: false //Visible state before show
      };

      uiw._elements = {
        $element : $(uiw.element[0]) //Affected element
      };

    }, //_setWidgetVars

    /**
     * Create function: Called the first time widget is associated to the object
     * Does all the required setup etc and binds change event
     */
    _create: function(){
      var uiw = this;

      uiw._setWidgetVars();

      var consoleGroupName = uiw._scope + '._create';
      // apex.debug.groupCollapsed(consoleGroupName);
      apex.debug.log('this:', uiw);
      apex.debug.log('element:', uiw.element[0]);

      // Need to add this so can easily close any open dialogs before submitting page
      uiw._elements.$element.addClass(oosDialog.className);

      // apex.debug.groupEnd(consoleGroupName);
    },//_create

    /**
     * Removes all functionality associated with the oosdialog
     * Will remove the change event as well
     * Odds are this will not be called from APEX.
     */
    destroy: function() {
      var uiw = this;

      apex.debug.log(uiw._scope, 'destroy', uiw);
      $.Widget.prototype.destroy.apply(uiw, arguments); // default destroy
      // unregister dialog
      uiw._elements.$element.dialog('destroy')
    },//destroy

    /**
     * Closes the dialog window
     * @param event
     * @ui
     */
    close: function(event, ui){
      var uiw = this;
      var consoleGroupName = uiw._scope + '.close';
      // apex.debug.groupCollapsed(consoleGroupName);
      // apex.debug.logParams();
      apex.debug.log('uiw: ', uiw);

      //Destroy the jQuery UI elements so that it displays as if dialog had not been applied
      uiw._elements.$element.dialog( "destroy" );

      //Show only if previous state was show
      if ((uiw._values.beforeShowVisible && uiw.options.onCloseVisibleState == 'prev') || uiw.options.onCloseVisibleState == 'show'){
        uiw._elements.$element.show();
      }
      else {
        uiw._elements.$element.hide();
      }

      //Trigger custom APEX Event
      uiw._elements.$element.trigger('cfpluginapexdialogclose', {event: event, ui: ui});

      // apex.debug.groupEnd(consoleGroupName);
    }//close

  }); //ui.oosdialog

  $.extend($.ui.oosdialog, {
    /**
     * Function to be called from the APEX Dynamic Action process
     * No values are passed in
     * "this" is the APEX DA "this" object
     */
    daDialog: function(){
      var scope = '$.ui.oosdialog.daDialog';
      var daThis = this; //Note that "this" represents the APEX Dynamic Action object
      // apex.debug.groupCollapsed(scope);
      apex.debug.log('APEX DA this: ' , daThis);

      //Set options
      var options = {
        modal: daThis.action.attribute01 === 'false' ? false : true,
        closeOnEscape: daThis.action.attribute02 === 'false' ? false : true,
        title: daThis.action.attribute03,
        onCloseVisibleState: daThis.action.attribute04
      };

      for(var i = 0, end = daThis.affectedElements.length; i < end; i++){
        apex.debug.log('Dialoging: ', daThis.affectedElements[i]);
        $(daThis.affectedElements[i]).oosdialog(options);
      }//for

      // apex.debug.groupEnd(scope);
    },//daDialog

    /**
     * Close dialog window(s)
     * No values are passed in
     * "this" is the APEX DA "this" object
     */
    daClose: function(){
      var scope = '$.ui.oosdialog.daClose';
      var daThis = this; //Note that "this" represents the APEX Dynamic Action object
      // apex.debug.groupCollapsed(scope);
      apex.debug.log('APEX DA this: ' , daThis);

      for(var i = 0, end = daThis.affectedElements.length; i < end; i++){
        apex.debug.log('Closing: ', daThis.affectedElements[i]);
        $(daThis.affectedElements[i]).oosdialog('close');
      }//for

      // apex.debug.groupEnd(scope);
    },//daClose

    /**
     * Handles the apex.submit process (see Issue #1)
     * Need to do this for APEX 5.0 as jQuery UI 1.10 applies the dialog to the DOM
     * Close all the dialogs
     * Only run this once
     */
    closeBeforeApexSubmit: function(){
      $(apex.gPageContext$).on("apexpagesubmit.oosdialog", function() {
        apex.debug.log('apexpagesubmit.oosdialog: Closing open dialogs');

        $('.' + oosDialog.className).each(function(i){
          var $this = $(this);

          // The additional $this.data('ui-dialog') is required since destroy call above removes this
          if ($this.data('ui-oosdialog') && $this.data('ui-dialog') && $this.dialog('isOpen')){
            apex.debug.log('Closing:', $this);
            $this.oosdialog('close');
          }//if

        });//$('.oos-dialog')
      });//$(apex.gPageContext$)
    }//closeBeforeApexSubmit

  });//Extend

})(apex.jQuery);
