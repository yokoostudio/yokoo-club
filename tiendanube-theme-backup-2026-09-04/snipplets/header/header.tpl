{# Site Overlay #}
<div class="js-overlay site-overlay" style="display: none;"></div>

{# Header #}

{% set header_left_with_big_search = settings.logo_position_desktop == 'left' and settings.search_big_desktop %}

{# Header logo dynamic classes #}

{% set header_logo_mobile_classes = settings.logo_position_mobile == 'below' ? 'head-logo-below' : settings.logo_position_mobile == 'center' ? 'head-logo-center' : 'head-logo-inline' %}
{% set header_logo_desktop_classes = settings.logo_position_desktop == 'center' ? 'head-logo-md-center' : settings.logo_position_desktop == 'left' ? 'head-logo-md-left' %}

{% set has_languages = languages | length > 1 and settings.languages_header %}

{# Logo mobile dynamic classes #}

{% if settings.logo_position_mobile == 'below' %}
    {% set logo_mobile_classes = 'col-12 text-center order-last pt-3 pt-md-0 pb-2 pb-md-0' %}
{% else %}
    {% set logo_mobile_classes = settings.logo_position_mobile == 'center' ? 'text-center' : 'order-first text-left' %}
{% endif %}
{% set logo_mobile_centered_without_offset = (settings.search_type_mobile == 'hidden' or settings.search_type_mobile == 'search_big') and settings.logo_position_mobile != 'left' %}

{# Logo desktop dynamic classes + utilities desktop order #}

{% set logo_desktop_classes = settings.logo_position_desktop == 'center' ? 'col-md-6 order-md-0 text-md-center' : 'col-md-auto order-md-first text-md-left' %}

{# Conditions for transparent head on page load #}

{# Slider and video presence #}

{% if template == 'home' %}
    {% set has_main_slider = settings.slider and settings.slider is not empty %}
    {% set has_mobile_slider = settings.toggle_slider_mobile and settings.slider_mobile and settings.slider_mobile is not empty %}
    {% set has_slider = has_main_slider or has_mobile_slider %}
    {% set has_slider_above_the_fold = settings.home_order_position_1 == 'slider' and has_slider %}
    {% set has_video_above_the_fold = settings.home_order_position_1 == 'video' and settings.video_embed %}
    {% set is_video_or_slider_above_the_fold = has_slider_above_the_fold or has_video_above_the_fold %}
{% endif %}

{# Transparent head conditions #}

{% set head_transparent_type_on_section = template == 'home' and settings.head_transparent and settings.head_transparent_type == 'slider_and_video' and (has_slider or settings.video_embed) %}
{% set head_transparent_type_always = settings.head_transparent and settings.head_transparent_type == 'all' %}
{% set head_transparent = (head_transparent_type_on_section or head_transparent_type_always) %}
{% set head_transparent_with_media = head_transparent and is_video_or_slider_above_the_fold %}

{% set header_transparent_classes = head_transparent_type_always ? 'js-head-mutator head-transparent' : head_transparent_type_on_section ? 'js-head-mutator head-transparent-on-section' %}
{% set head_transparent_color_class = head_transparent and settings.head_transparent_contrast_options ? 'head-transparent-contrast' %}
{% set head_transparent_logo_class = head_transparent and settings.head_transparent_contrast_options and "logo-transparent.jpg" | has_custom_image ? 'head-transparent-logo' %}

{# Header position type #}

{% set head_position_mobile = head_transparent_with_media ? 'position-fixed' : 'position-sticky' %}
{% set head_position_desktop = settings.head_fix_desktop 
    ? (head_transparent_with_media ? 'position-fixed-md' : 'position-sticky-md')
    : (head_transparent_with_media ? 'position-absolute-md' : 'position-relative-md') %}

{# Utilities classes #}

{% if settings.logo_position_mobile == 'below' %}
    {% set utilities_hamburger_mobile_classes = 'col' %}
{% else %}
    {% set utilities_hamburger_mobile_classes = settings.logo_position_mobile == 'center' ? 'col-2' : 'col-auto' %}
{% endif %}
{% set utilities_desktop_classes = settings.logo_position_desktop == 'left' ? 'js-utility-col desktop-utility-col' : 'col-md-3' %}

{% set header_search_desktop_classes = settings.search_big_desktop ? 'head-search-md-big' : 'head-search-md-icon' %}

{# Header visibility classes #}

{% set show_inline_desktop_hide_mobile_class = 'd-none d-md-inline-block' %}
{% set show_inline_mobile_hide_desktop_class = 'd-inline-block d-md-none' %}
{% set show_block_desktop_hide_mobile_class = 'd-none d-md-block' %}
{% set show_block_mobile_hide_desktop_class = 'd-block d-md-none' %}

{# Utilities conditions #}

<header class="js-head-main head-main {{ header_transparent_classes }} {{ head_transparent_color_class }} {{ head_transparent_logo_class }} {{ header_logo_mobile_classes }} {{ header_logo_desktop_classes }} {{ head_position_mobile }} {{ head_position_desktop }} {{ header_search_desktop_classes }} transition-soft" data-store="head">
    {# Adversiting bar #}
    {% if settings.ad_bar %}
        {% snipplet "header/header-advertising.tpl" %}
    {% endif %}
    <div class="js-head-logo-row head-logo-row position-relative container transition-soft{% if has_languages and settings.search_type_mobile == 'search_icon' %} head-logo-languages{% endif %}">
        <div class="{% if not settings.head_fix_desktop %}js-nav-logo-bar{% endif %} row no-gutters align-items-center{% if header_left_with_big_search %} justify-md-content-end{% endif %}">

            {# Menu icon #}

            <div class="js-utility-col transition-soft {{ utilities_hamburger_mobile_classes }} col-utility d-md-none">
                {% include "snipplets/header/header-utilities.tpl" with {use_menu: true} %}
            </div>

            {# Logo #}

            <div class="js-logo-container logo-container-col col transition-soft {{ logo_mobile_classes }} {{ logo_desktop_classes }}{% if header_left_with_big_search %} mr-md-auto{% endif %}">
                {% set logo_size_class = '' %}
                {% if settings.logo_position_mobile == 'below' and settings.logo_size == 'default' %}
                    {% set logo_size_class = template == 'home' ? 'logo-big ' : 'logo-medium' %}
                {% else %}
                    {% set logo_size_class = settings.logo_size == 'small' ? 'logo-img-small' : settings.logo_size == 'medium' ? 'logo-img-medium' : settings.logo_size == 'big' ? 'logo-img-big' %}
                {% endif %}

                {% set logo_img_size = settings.logo_position_desktop == 'left' ? 'large' : 'huge' %}
                {{ component('logos/logo', {logo_size: logo_img_size, logo_img_classes: 'transition-soft ' ~ logo_size_class, logo_text_classes: 'h3 m-0'}) }}

                {% if template == 'home' and settings.head_transparent and settings.head_transparent_contrast_options and "logo-transparent.jpg" | has_custom_image %}
                    {{ component('logos/logo-transparent-header', {logo_size: logo_img_size, logo_img_name: 'logo-transparent.jpg', logo_img_classes: 'transition-soft '  ~ logo_size_class}) }}
                {% endif %}
            </div>

            {# Desktop navigation next to logo #}

            {% if settings.logo_position_desktop == 'left' and not settings.search_big_desktop %}
                {# Desktop nav next logo #}
                <div class="js-desktop-nav-col desktop-nav-col transition-soft col {{ show_inline_desktop_hide_mobile_class }} align-items-center">
                    {% snipplet "navigation/navigation.tpl" %}
                </div>
            {% endif %}

            {# Search: Icon or box #}

            <div class="js-utility-col js-search-utility transition-soft {{ utilities_desktop_classes }} col-utility 
            {% if settings.logo_position_desktop == 'center' %}
                order-md-first
            {% endif %} 
            {% if settings.search_type_mobile == 'hidden' %}
                {{ show_inline_desktop_hide_mobile_class }}
            {% endif %}
            {% if settings.search_type_mobile == 'search_big' %}
                mt-2 mt-md-0 
                {% if settings.logo_position_mobile == 'below' %}
                    pt-1 pt-md-0 order-last
                {% else %}
                    pt-2 order-3 
                {% endif %}
                pt-md-0
                w-md-auto w-100 
                {% if settings.logo_position_desktop == 'left' %}order-md-0{% endif %}
            {% else %} 
                col-auto
            {% endif %}">
                {% include "snipplets/header/header-utilities.tpl" with {use_search: true} %}
                {% if settings.logo_position_desktop == 'center' or header_left_with_big_search or settings.search_type_mobile == 'search_big' %}
                    <span class="{% if settings.search_type_mobile == 'search_big' %}position-relative{% else %}d-none{% endif %} d-md-flex {% if header_left_with_big_search %}position-relative-md mr-md-3 pr-md-1{% elseif not settings.search_big_desktop %}position-static-md{% endif %}">
                        {% include "snipplets/header/header-search.tpl" with{ not_padding: true } %}
                    </span>
                {% endif %}
            </div>

            <div class="js-utility-col transition-soft {{ utilities_desktop_classes }} d-flex {% if logo_mobile_centered_without_offset %}col-2 justify-content-end col-md-auto{% else %}col-auto{% endif %} col-utility {% if settings.logo_position_desktop == 'center' %}justify-content-md-end{% endif %}">

                {# Languages #}

                {% if has_languages %}
                    {% include "snipplets/header/header-utilities.tpl" with {use_languages: true} %}
                {% endif %}

                {# Account desktop icon #}

                <span class="{{ show_inline_desktop_hide_mobile_class }}">
                    {% include "snipplets/header/header-utilities.tpl" with {use_account: true, icon_only: true} %}
                </span>

                {# Cart icon #}

                {% include "snipplets/header/header-utilities.tpl" %}
            </div>

            {# Add to cart notification #}

            {% if settings.ajax_cart %}
                {% if not settings.head_fix_desktop %}
                    <div class="{{ show_block_mobile_hide_desktop_class }}">
                {% endif %}
                        {% include "snipplets/notification.tpl" with {add_to_cart: true} %}
                {% if not settings.head_fix_desktop %}
                    </div>
                {% endif %}
            {% endif %}

        </div>
    </div>   

    {# Desktop navigation below logo #}

    {% if settings.logo_position_desktop != 'left' or header_left_with_big_search %}
        {# Desktop nav below logo #}
        <div class="container {{ show_block_desktop_hide_mobile_class }} {% if settings.logo_position_desktop == 'center' %}text-center{% endif %}">
            {% snipplet "navigation/navigation.tpl" %}
        </div>
    {% endif %}
 
    {% include "snipplets/notification.tpl" with {order_notification: true} %}
</header>

{{ component('nubesdk-slot', { type: "after_header" }) }}

{# Show cookie validation message #}

{% include "snipplets/notification.tpl" with {show_cookie_banner: true} %}

{# Add to cart notification for non fixed header #}

{% if settings.ajax_cart and not settings.head_fix_desktop %}
    <div class="{{ show_block_desktop_hide_mobile_class }}">
        {% include "snipplets/notification.tpl" with {add_to_cart: true, add_to_cart_fixed: true} %}
    </div>
{% endif %}


{# Cross selling promotion notification on add to cart #}

{% embed "snipplets/modal.tpl" with {
    modal_id: 'js-cross-selling-modal',
    modal_class: 'bottom modal-bottom-sheet h-auto overflow-none modal-body-scrollable-auto',
    modal_header: true,
    modal_header_class: 'p-2 m-2 w-100',
    modal_position: 'bottom',
    modal_transition: 'slide',
    modal_footer: true,
    modal_width: 'centered-md m-0 p-0 modal-full-width modal-md-width-400px',
    modal_close_class: 'mr-4'
} %}
    {% block modal_head %}
        {{ '¡Descuento exclusivo!' | translate }}
    {% endblock %}

    {% block modal_body %}
        {# Promotion info and actions #}

        <div class="js-cross-selling-modal-body" style="display: none"></div>
    {% endblock %}
{% endembed %}

{% include "snipplets/header/header-modals.tpl" %}
