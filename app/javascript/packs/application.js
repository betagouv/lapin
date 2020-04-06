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
require("chartkick")
require("chart.js")
import 'bootstrap';
import 'moment/moment.js';
import 'jquery-mask-plugin';
import 'moment/locale/fr.js';
import 'holderjs/holder.min';
import 'jquery-slimscroll/jquery.slimscroll';
import 'metismenu/dist/metisMenu.min';
import 'select2/dist/js/select2.full.min.js';
import 'select2/dist/js/i18n/fr.js';
import { Datetimepicker } from 'packs/components/datetimepicker';
import { Avatar } from 'packs/components/avatar';
import { Menu } from 'packs/components/menu';
import { Layout } from 'packs/components/layout';
import { Modal } from 'packs/components/modal';
import { Rightbar } from 'packs/components/rightbar';
import { Rdvstatus } from 'packs/components/rdvstatus';
import { InviteUserOnCreate } from 'packs/components/invite-user-on-create';
import { PopulateLibelle } from 'packs/components/populate-libelle';
import { Analytic } from 'packs/components/analytic.js';
import { PlacesInput } from 'packs/components/places-input.js';
import { ShowHidePassword } from 'packs/components/show-hide-password.js';
import 'packs/components/calendar';
import 'packs/components/select2';
import 'packs/components/tooltip';
import 'packs/components/sentry';
import 'packs/components/browser-detection';
import "actiontext";
import { Application } from "stimulus";
import { definitionsFromContext } from "stimulus/webpack-helpers";

const application = Application.start();
const context = require.context("./controllers", true, /\.js$/);
application.load(definitionsFromContext(context));

new Modal();
new Rightbar();

if(ENV.ENV == "production") var analytic = new Analytic();

global.$ = require('jquery');

$(document).on('shown.bs.modal', '.modal', function(e) {
  if(analytic) analytic.trackModalView(e);
  new Datetimepicker();
  new InviteUserOnCreate();
});

$(document).on('shown.rightbar', '.right-bar', function(e) {
  if(analytic) analytic.trackRightbarView(e);
  $('input[type="tel"]').mask('00 00 00 00 00')
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
    theme: "bootstrap4"
  });
  new Datetimepicker();
  new Rdvstatus();
  $(".tooltip").tooltip("hide");
});

$(document).on('hide.bs.modal', '.modal', function(e) {
  $('.modal-backdrop').remove();
  $("[data-behaviour='datepicker'], [data-behaviour='datetimepicker'], [data-behaviour='timepicker']").datetimepicker('destroy');
});

$(document).on('turbolinks:load', function() {
  if(analytic) analytic.trackPageView();
  Holder.run();

  let menu = new Menu();
  let layout = new Layout();

  layout.init();
  menu.init();
  new Avatar().init();

  $('input[type="tel"]').mask('00 00 00 00 00')
  $(window).on('resize', function(e) {
    e.preventDefault();
    layout.init();
    menu.resetSidebarScroll();
  });

  new PlacesInput(document.querySelector('.places-js-container'));

  new PopulateLibelle();

  new Datetimepicker();

  new InviteUserOnCreate();

  new ShowHidePassword();
});
