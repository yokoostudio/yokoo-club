{# Cookie validation #}

{% if show_cookie_banner and not params.preview and not should_omit_consent_management %}
    <div class="js-notification js-notification-cookie-banner notification notification-fixed-bottom notification-primary text-left" style="display: none;">
        <div class="container-fluid">
            <div class="row justify-content-center align-items-center">
                <div class="col-12 col-md-auto mb-1 mb-md-0 pr-md-0 text-center">
                    {{ 'Al navegar por este sitio <strong>aceptás el uso de cookies</strong> para agilizar tu experiencia de compra.' | translate }}
                </div>
                <div class="col-12 col-md-auto text-center">
                    <a href="#" class="js-notification-close js-acknowledge-cookies btn-link" data-amplitude-event-name="cookie_banner_acknowledge_click">{{ "Entendido" | translate }}</a>
                </div>
            </div>
        </div>
    </div>
{% endif %}

{% if order_notification and status_page_url_notification %}
    <div class="js-notification js-notification-status-page notification notification-primary notification-order w-100" style="display:none;" data-url="{{ status_page_url_notification }}">
        <div class="container">
            <div class="row">
                <div class="col">
                    <a class="d-block d-sm-inline mr-3 mr-sm-2" href="{{ status_page_url_notification }}"><span class="btn-link font-small">{{ "Seguí acá" | translate }}</span> {{ "tu última compra" | translate }}</a>
                    <a class="js-notification-close js-notification-status-page-close notification-close position-relative-md" href="#">
                        <svg class="icon-inline icon-lg"><use xlink:href="#times"/></svg>
                    </a>
                </div>
            </div>
        </div>
    </div>
{% endif %}
{% if add_to_cart %}
    {% include "snipplets/notification-cart.tpl" %}
{% endif %}
