{% embed "snipplets/modal.tpl" with{modal_id: 'home-modal', modal_class: 'home-promotional modal-bottom-sheet modal-shadow', modal_position: 'bottom', modal_transition: 'slide', modal_header_title: true, modal_footer: false, modal_width: 'docked-md modal-docked-small modal-docked-md-right', modal_body_class: 'text-center' } %}
    {% if settings.home_popup_title %}
        {% block modal_head %}
            {{ settings.home_popup_title }}
        {% endblock %}
    {% endif %}
    {% block modal_body %}

        {% if "home_popup_image.jpg" | has_custom_image %}
            <img src="{{ 'images/empty-placeholder.png' | static_url }}" data-srcset='{{ "home_popup_image.jpg" | static_url | settings_image_url('large') }} 480w, {{ "home_popup_image.jpg" | static_url | settings_image_url('huge') }} 640w' class="lazyload fade-in modal-img-full d-block"/>
        {% endif %}

        {% if settings.home_popup_txt %}
            <p class="p-3 m-0">{{ settings.home_popup_txt }}</p>
        {% endif %}

        {% if settings.home_news_box %}
            <div id="news-popup-form-container" class="newsletter pb-1">
                <form id="news-popup-form" method="post" action="/winnie-pooh" class="js-news-form" data-store="newsletter-form-popup">
                    <div class="js-newsletter position-relative">
                        {% embed "snipplets/forms/form-input.tpl" with{input_for: 'email', type_email: true, input_name: 'email', input_id: 'email', input_placeholder: 'Ingresá tu email...' | translate, input_custom_class: "js-mandatory-field", input_aria_label: 'Email' | translate, input_group_custom_class: 'm-0' } %}
                        {% endembed %}
                        <div class="winnie-pooh" style="display: none;">
                            <label for="winnie-pooh-newsletter">{{ "No completar este campo" | translate }}</label>
                            <input id="winnie-pooh-newsletter" type="text" name="winnie-pooh"/>
                        </div>
                        <input type="hidden" name="name" value="{{ "Sin nombre" | translate }}" />
                        <input type="hidden" name="message" value="{{ "Pedido de inscripción a newsletter" | translate }}" />
                        <input type="hidden" name="type" value="newsletter" />
                        <input type="submit" name="contact" class="js-news-popup-submit btn btn-link newsletter-btn" value="{{ "Enviar" | translate }}" />
                        <span class="js-news-spinner" style="display: none;">
                            <svg class="icon-inline icon-xs icon-spin icon-w-2em newsletter-btn newsletter-btn-spinner"><use xlink:href="#spinner-third"/></svg>
                        </span>
                    </div> 
                    <div class="js-news-popup-success alert alert-success" style='display: none;'>{{ "¡Gracias por suscribirte! A partir de ahora vas a recibir nuestras novedades en tu email" | translate }}</div>
                    <div class="js-news-popup-failed alert alert-danger" style='display: none;'>{{ "Necesitamos tu email para enviarte nuestras novedades." | translate }}</div>                   
                </form>
            </div>
        {% elseif settings.home_popup_btn and settings.home_popup_url %}
            <div class="{% if settings.home_popup_txt %}px-3 pb-3{% else %}p-3{% endif %}">
                <a href="{{ settings.home_popup_url }}" class="btn-link font-small">{{ settings.home_popup_btn }}</a>
            </div>
        {% endif %}

    {% endblock %}
{% endembed %}