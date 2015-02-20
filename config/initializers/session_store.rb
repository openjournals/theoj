# Be sure to restart your server when you modify this file.

Theoj::Application.config.session_store :cookie_store,
                                        key:           '_theoj_session',
                                        expire_after:  2.weeks,
                                        http_only:     true
