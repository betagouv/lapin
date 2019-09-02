/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb
require("@rails/ujs").start()
require("turbolinks").start()

import 'bootstrap';
import 'moment/moment.js';
import 'moment/locale/fr.js';
import 'holderjs/holder.min';
import 'jquery-slimscroll/jquery.slimscroll';
import 'metismenu/dist/metisMenu.min';
import 'select2/dist/js/select2.min.js';
import { Datetimepicker } from 'packs/components/datetimepicker';
import { Avatar } from 'packs/components/avatar';
import { Menu } from 'packs/components/menu';
import { Layout } from 'packs/components/layout';
import { Modal } from 'packs/components/modal';
import { Rightbar } from 'packs/components/rightbar';
import { Analytic } from 'packs/components/analytic.js.erb';
import { PlacesInput } from 'packs/components/places-input.js.erb';
import 'packs/components/calendar';
import "actiontext";
import { Application } from "stimulus";
import { definitionsFromContext } from "stimulus/webpack-helpers";

const application = Application.start();
const context = require.context("./controllers", true, /\.js$/);
application.load(definitionsFromContext(context));

new Modal();
new Rightbar();
var analytic = new Analytic();

$(document).on('shown.bs.modal', '.modal', function(e) {
  analytic.trackModalView(e);
});

$(document).on('shown.rightbar', '.right-bar', function(e) {
  analytic.trackRightbarView(e);
  $('.right-bar .slimscroll-menu').slimscroll({
    height: 'auto',
    position: 'right',
    size: "8px",
    color: '#9ea5ab',
    wheelStep: 5,
    touchScrollStep: 20
  });
  new PlacesInput(document.querySelector('.places-js-container'));
  $( ".select2-input").select2({
    theme: "bootstrap"
  });
  new Datetimepicker();
});

$(document).on('hide.bs.modal', '.modal', function(e) {
  $('.modal-backdrop').remove();
  $("[data-behaviour='datepicker'], [data-behaviour='datetimepicker'], [data-behaviour='timepicker']").datetimepicker('destroy');
});

$(document).on('turbolinks:load', function() {
  analytic.trackPageView();
  Holder.run();

  let menu = new Menu();
  let layout = new Layout();

  layout.init();
  menu.init();
  new Avatar().init();

  $(window).on('resize', function(e) {
    e.preventDefault();
    layout.init();
    menu.resetSidebarScroll();
  });

  new PlacesInput(document.querySelector('.places-js-container'));

  $( ".select2-input").select2({
    theme: "bootstrap"
  });

  new Datetimepicker();
});
