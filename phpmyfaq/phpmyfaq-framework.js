/*
 *   Copyright 2014 Peter Kehl
* This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/.*/
"use strict";

// If you extend this framework from another file, see https://code.google.com/p/selite/wiki/TestFramework#Extending_a_test_framework
/** @type{object} A namespace-like object in the global scope.*/
var phpMyFAQ;
if( phpMyFAQ===undefined ) {
    phpMyFAQ= {
        /** @type {string}*/
        selectedUserId: undefined,
        /** @type {SeLiteData.Db}*/
        db: new SeLiteData.Db( SeLiteData.getStorageFromSettings() )
    };
}
(function() {
    var console= Components.utils.import("resource://gre/modules/devtools/Console.jsm", {}).console;
    console.warn('phpMyFAQ framework loading');
    /** @type {SeLiteSettings.Module} */
    var commonSettings= SeLiteSettings.loadFromJavascript( 'extensions.selite-settings.common' );
    commonSettings.getField( 'roles' ).addKeys( ['admin', 'editor'] );
    // @TODO re-apply modified default value when I reload Selenium IDE
    // If you use ExitConfirmationChecker add-on, then set its default value to TODO: Basic or Advanced
    /*if( commonSettings.getField('exitConfirmationCheckerMode') ) {
        //commonSettings.getField('exitConfirmationCheckerMode').setDefaultKey( 'skipRevertedChanges' );
    }/**/

        FUDforum.tables= {};
        FUDforum.tables.user= new SeLiteData.Table( {
           db:  FUDforum.db,
           name: 'user',
           columns: ['user_id', 'login', 'session_id', 'session_timestamp', 'ip', 'account_status', 'last_login', 'auth_source', 'member_since', 'remember_me', 'success'
           ],
           primary: 'user_id' // However, for purpose of matching users I usually use 'login'
        });
        FUDforum.tables.userdata= new SeLiteData.Table( {
           db:  FUDforum.db,
           name: 'userdata',
           columns: ['user_id', 'last_modified', 'display_name', 'email'
           ],
           primary: 'user_id'
        });
        FUDforum.tables.userlogin= new SeLiteData.Table( {
           db:  FUDforum.db,
           name: 'userlogin',
           columns: ['login', 'pass'
           ],
           primary: 'login'
        });
        FUDforum.tables.user_group= new SeLiteData.Table( {
           db:  FUDforum.db,
           name: 'user_group',
           columns: ['user_id', 'group_id'],
           primary: ['user_id', 'group_id']//@TODO implement?
        });
        FUDforum.tables.user_right= new SeLiteData.Table( {
           db:  FUDforum.db,
           name: 'user_right',
           columns: ['user_id', 'right_id'],
           primary: ['user_id', 'right_id']
        });
        FUDforum.tables.faqvisits= new SeLiteData.Table( {
           db:  FUDforum.db,
           name: 'faqvisits',
           columns: ['id', 'lang', 'visits', 'last_visit'],
           primary: ['id', 'login']
        });
        
        FUDforum.formulas= {};
        FUDforum.formulas.user= new SeLiteData.RecordSetFormula( {
            table: FUDforum.tables.user,
            columns: new SeLiteData.Settable().set( FUDforum.tables.user.name/* same as 'user' */, SeLiteData.RecordSetFormula.ALL_FIELDS )
        });
        console.warn('phpMyFaq framework loaded');
})();