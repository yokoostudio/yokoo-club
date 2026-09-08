{# /*============================================================================
  #Home featured grid
==============================================================================*/

#Properties

#Featured Slider

#}

{% set featured_products = featured_products | default(false) %}
{% set new_products = new_products | default(false) %}
{% set sale_products = sale_products | default(false) %}

{# Check if slider is used #}

{% set has_featured_products_and_slider = featured_products and settings.featured_products_format == 'slider' %}
{% set has_new_products_and_slider = new_products and settings.new_products_format == 'slider' %}
{% set has_sale_products_and_slider = sale_products and settings.sale_products_format == 'slider' %}
{% set use_slider = has_featured_products_and_slider or has_new_products_and_slider or has_sale_products_and_slider %}

{% if featured_products %}
    {% set sections_products = sections.primary.products %}
    {% set section_name = 'primary' %}
    {% set section_columns_desktop = settings.featured_products_desktop %}
    {% set section_columns_mobile = settings.featured_products_mobile %}
    {% set section_slider = settings.featured_products_format == 'slider' %}
    {% set section_format = settings.featured_products_format %}
    {% set section_id = 'featured' %}
    {% set section_title = settings.featured_products_title %}
{% endif %}
{% if new_products %}
    {% set sections_products = sections.new.products %}
    {% set section_name = 'new' %}
    {% set section_columns_desktop = settings.new_products_desktop %}
    {% set section_columns_mobile = settings.new_products_mobile %}
    {% set section_slider = settings.new_products_format == 'slider' %}
    {% set section_format = settings.new_products_format %}
    {% set section_id = 'new' %}
    {% set section_title = settings.new_products_title %}
{% endif %}
{% if sale_products %}
    {% set sections_products = sections.sale.products %}
    {% set section_name = 'sale' %}
    {% set section_columns_desktop = settings.sale_products_desktop %}
    {% set section_columns_mobile = settings.sale_products_mobile %}
    {% set section_slider = settings.sale_products_format == 'slider' %}
    {% set section_format = settings.sale_products_format %}
    {% set section_id = 'sale' %}
    {% set section_title = settings.sale_products_title %}
{% endif %}

<div class="js-products-{{ section_id }}-container container">
    <div class="row">
        <div class="col-12">
            <h2 class="js-products-{{ section_id }}-title section-title h3 mt-3 mb-4 pb-2 text-center" {% if not section_title %} style="display:none;"{% endif %}>{{ section_title }}</h2>
            {% if use_slider %}
                <div class="js-swiper-{{ section_id }} swiper-container">
            {% endif %}
                    <div class="js-products-{{ section_id }}-grid {% if use_slider %} swiper-wrapper{% else %}row row-grid{% endif %}" data-desktop-columns="{{ section_columns_desktop }}" data-mobile-columns="{{ section_columns_mobile }}" data-format="{{ section_format }}">
                        {% for product in sections_products %}
                            {% if use_slider %}
                                {% include 'snipplets/grid/item.tpl' with {'slide_item': true, 'section_name': section_name, 'section_columns_desktop': section_columns_desktop, 'section_columns_mobile': section_columns_mobile } %}
                            {% else %}
                                {% include 'snipplets/grid/item.tpl' %}
                            {% endif %}
                        {% endfor %}
                    </div>
            {% if use_slider %}
                </div>
                <div class="js-products-{{ section_id }}-controls mt-2 text-center">
                    <div class="js-swiper-{{ section_id }}-prev swiper-button-prev svg-icon-text">
                        <svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#arrow-long"/></svg>
                    </div>
                    <div class="js-swiper-{{ section_id }}-pagination swiper-pagination-fraction"></div>
                    <div class="js-swiper-{{ section_id }}-next swiper-button-next svg-icon-text">
                        <svg class="icon-inline icon-lg"><use xlink:href="#arrow-long"/></svg>
                    </div>
                </div>
            {% endif %}
        </div>
    </div>
</div>
