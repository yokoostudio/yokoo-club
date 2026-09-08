{# /*============================================================================
  #Item grid
==============================================================================*/

#Properties

#Slide Item

#}

{% set slide_item = slide_item | default(false) %}

{% if template == 'home'%}
    {% set columns_desktop = section_columns_desktop %}
    {% set columns_mobile = section_columns_mobile %}
    {% set section_slider = section_slider %}
{% else %}
    {% set columns_desktop = settings.grid_columns_desktop %}
    {% set columns_mobile = settings.grid_columns_mobile %}
    {% if template == 'product'%}
        {% set section_slider = true %}
    {% endif %}
{% endif %}

{# Subscription only detection #}
{% set is_subscription_only = product.isSubscriptionOnly() %}

{# Item image slider #}

{% set show_image_slider = 
    (template == 'category' or template == 'search')
    and settings.product_item_slider 
    and not slide_item
    and not reduced_item 
    and not has_filters
    and product.other_images
%}

{% if show_image_slider %}
    {% set slider_controls_container_class = 'item-slider-controls-container svg-icon-text d-none d-md-block' %}
    {% set control_next_svg_id = 'arrow-long' %}
    {% set control_prev_svg_id = 'arrow-long' %}
{% endif %}

{# Secondary images #}

{% set show_secondary_image = settings.product_hover %}

{% if slide_item %}
    <div class="swiper-slide">
{% endif %}
    <div class="js-item-product{% if slide_item %} js-item-slide p-0{% endif %}{% if not slide_item %} col-{% if columns_mobile == 1 %}12{% else %}6{% endif %} col-md-{% if columns_desktop == 2 %}6{% elseif columns_desktop == 3 %}4{% else %}3{% endif %}{% endif %} item-product {% if reduced_item %}item-product-reduced{% endif %} col-grid" data-product-type="list" data-product-id="{{ product.id }}" data-store="product-item-{{ product.id }}" data-component="product-list-item" data-component-value="{{ product.id }}">
        <div class="js-item-info-container item{% if slide_item %} mb-0{% endif %}">
            {% if (settings.quick_shop or settings.product_color_variants) and not reduced_item %}
                <div class="js-product-container js-quickshop-container{% if product.variations %} js-quickshop-has-variants{% endif %} position-relative" data-variants="{{ product.variants_object | json_encode }}" data-quickshop-id="quick{{ product.id }}">
            {% endif %}
            {% set product_url_with_selected_variant = has_filters ?  ( product.url | add_param('variant', product.selected_or_first_available_variant.id)) : product.url  %}

            {# Set how much viewport space the images will take to load correct image #}

            {% if params.preview %}
                {% set mobile_image_viewport_space = '100' %}
                {% set desktop_image_viewport_space = '50' %}
            {% else %}
                {% if columns_mobile == 2 %}
                    {% set mobile_image_viewport_space = '50' %}
                {% else %}
                    {% set mobile_image_viewport_space = '100' %}
                {% endif %}

                {% if columns_desktop == 4 %}
                    {% set desktop_image_viewport_space = '25' %}
                {% elseif columns_desktop == 3 %}
                    {% set desktop_image_viewport_space = '33' %}
                {% else %}
                    {% set desktop_image_viewport_space = '50' %}
                {% endif %}
            {% endif %}

            {% set image_classes = 'js-item-image lazyautosizes ' ~ (not image_priority_high ? 'lazyload') ~ ' fade-in img-absolute img-absolute-centered' %}
            {% set data_expand = show_image_slider ? '50' : '-10' %}

            {% set floating_elements %}
                {% if not reduced_item %}
                    {% include 'snipplets/labels.tpl' with {labels_floating: true} %}
                {% endif %}
            {% endset %}

            {{ component(
                'product-item-image', {
                    image_lazy: true,
                    image_lazy_js: true,
                    image_data_expand: data_expand,
                    image_secondary_data_sizes: 'auto',
                    image_sizes: '(max-width: 768px)' ~ mobile_image_viewport_space ~ 'vw, (min-width: 769px)' ~ desktop_image_viewport_space ~ 'vw',
                    secondary_image: show_secondary_image,
                    slider: show_image_slider,
                    placeholder: true,
                    image_priority_high: image_priority_high,
                    custom_content: floating_elements,
                    slider_pagination_container: true,
                    product_item_image_classes: {
                        image_container: 'item-image' ~ (columns == 1 ? ' item-image-big') ~ (show_image_slider ? ' item-image-slider'),
                        image_padding_container: 'js-item-image-padding position-relative d-block',
                        image: image_classes,
                        image_featured: 'item-image-featured',
                        image_secondary: 'item-image-secondary',
                        slider_container: 'swiper-container position-absolute h-100 w-100',
                        slider_wrapper: 'swiper-wrapper',
                        slider_slide: 'swiper-slide item-image-slide',
                        slider_control_pagination_container: 'item-slider-pagination-container d-md-none',
                        slider_control_pagination: 'swiper-pagination item-slider-pagination',
                        slider_control: 'icon-inline icon-lg',
                        slider_control_prev_container: 'swiper-button-prev ' ~ slider_controls_container_class,
                        slider_control_prev: 'icon-flip-horizontal',
                        slider_control_next_container: 'swiper-button-next ' ~ slider_controls_container_class,
                        more_images_message: 'item-more-images-message',
                        placeholder: 'placeholder-fade',
                    },
                    control_next_svg_id: control_next_svg_id,
                    control_prev_svg_id: control_prev_svg_id,
                })
            }}

            {% if 
                ((settings.quick_shop and not product.isSubscribable()) or settings.product_color_variants)
                and product.available 
                and product.display_price 
                and product.variations 
                and not reduced_item 
            %}

                {# Hidden product form to update item image and variants: Also this is used for quickshop popup #}

                <div class="js-item-variants hidden">
                    <form class="js-product-form" method="post" action="{{ store.cart_url }}">
                        <input type="hidden" name="add_to_cart" value="{{product.id}}" />
                        {% if product.variations %}
                            {% include "snipplets/product/product-variants.tpl" with {quickshop: true} %}
                        {% endif %}
                        {% set state = store.is_catalog ? 'catalog' : (product.available ? product.display_price ? 'cart' : 'contact' : 'nostock') %}
                        {% set texts = {'cart': "Agregar al carrito", 'contact': "Consultar precio", 'nostock': "Sin stock", 'catalog': "Consultar"} %}

                        {# Add to cart CTA #}

                        {% set show_product_quantity = product.available and product.display_price %}

                        <div class="row">

                            {% if show_product_quantity %}
                                {% include "snipplets/product/product-quantity.tpl" with {quickshop: true} %}
                            {% endif %}

                            <div class="js-buy-button-container {% if show_product_quantity %}col-8 pl-md-0{% else %}col-12{% endif %} buy-button-container">

                                <input type="submit" class="js-addtocart js-prod-submit-form btn-add-to-cart btn btn-primary btn-big w-100 {{ state }}" value="{{ texts[state] | translate }}" {% if state == 'nostock' %}disabled{% endif %} />

                                {# Fake add to cart CTA visible during add to cart event #}

                                {% include 'snipplets/placeholders/button-placeholder.tpl' with {custom_class: "btn-big"} %}
                            </div>
                        </div>
                    </form>
                </div>

            {% endif %}
            {% set show_labels = not product.has_stock or product.compare_at_price or product.hasVisiblePromotionLabel %}
            <div class="item-description text-center" data-store="product-item-info-{{ product.id }}">
                <a href="{{ product_url_with_selected_variant }}" title="{{ product.name }}" aria-label="{{ product.name }}" class="item-link">

                    {{ component('nubesdk-slot', { type: "before_product_grid_item_name" }) }}

                    <div class="js-item-name item-name mb-2 font-small opacity-80" data-store="product-item-name-{{ product.id }}">{{ product.name }}</div>

                    {{ component('nubesdk-slot', { type: "after_product_grid_item_name" }) }}

                    {{ component('nubesdk-slot', { type: "before_product_grid_item_price" }) }}

                    {% if product.display_price %}
                        {% if is_subscription_only %}
                            {# Subscription only products: use subscription-price component with product_list location #}
                            {{ component('subscriptions/subscription-price', {
                                location: 'product_list',
                                subscription_classes: {
                                    container: 'item-price-container',
                                    price_compare: 'price-compare',
                                    price_with_subscription: 'item-price',
                                },
                            }) }}
                        {% else %}
                            {# Normal products: original price display #}
                            <div class="item-price-container" data-store="product-item-price-{{ product.id }}">
                                <span class="js-price-display item-price" data-product-price="{{ product.price }}">
                                    {{ product.price | money }}
                                </span>
                                {% if not reduced_item %}
                                    <span class="js-compare-price-display price-compare" {% if not product.compare_at_price or not product.display_price %}style="display:none;"{% else %}style="display:inline-block;"{% endif %}>
                                        {{ product.compare_at_price | money }}
                                    </span>
                                {% endif %}

                                {{ component('payment-discount-price', {
                                        visibility_condition: settings.payment_discount_price and not reduced_item,
                                        location: 'product',
                                        container_classes: "font-smallest mt-1",
                                    }) 
                                }}

                                {% if settings.product_installments and not reduced_item %}
                                    {{ component('installments', {'location' : 'product_item', container_classes: { installment: "item-installments mt-2"}}) }}
                                {% endif %}
                            </div>
                        {% endif %}

                        {# Subscription message - shown for all subscribable products (outside price conditional) #}
                        {% if not reduced_item %}
                            {{ component('subscriptions/subscription-message', {
                                subscription_classes: {
                                    container: 'font-smallest mt-1',
                                },
                            }) }}
                        {% endif %}
                    {% endif %}

                    {{ component('nubesdk-slot', { type: "after_product_grid_item_price" }) }}

                    {% if settings.product_color_variants and not reduced_item %}
                        {% include 'snipplets/grid/item-colors.tpl' %}
                    {% endif %}
                    {% if product.available and product.display_price and settings.quick_shop and not reduced_item %}
                        {% if settings.quick_shop %}

                            {% set quickshop_button_classes = 'btn-link btn-small-quickshop' %}

                            {% set state = store.is_catalog ? 'catalog' : (product.available ? product.display_price ? 'cart' : 'contact' : 'nostock') %}
                            {% set texts = {'cart': "Comprar", 'contact': "Consultar precio", 'nostock': "Sin stock", 'catalog': "Consultar"} %}

                            <div class="item-actions mt-2 pt-1">

                                {% if product.isSubscribable() %}

                                    {# Product with subscription will link to the product page #}

                                    {% if is_subscription_only %}
                                        {# Subscription only: convert to clickable link with "Suscribir" text #}
                                        {% set button_text = 'our_components.subscriptions.subscribe' | tt %}
                                        {% set button_title = button_text ~ ' ' ~ product.name %}
                                        <a href="{{ product_url_with_selected_variant }}" class="{{ quickshop_button_classes }}" title="{{ button_title }}" aria-label="{{ button_title }}">
                                            <span>{{ button_text }}</span>
                                            <svg class="icon-inline ml-1"><use xlink:href="#bag-small"/></svg>
                                        </a>
                                    {% else %}
                                        {# Subscribable (not subscription only): keep original span #}
                                        <span class="{{ quickshop_button_classes }}" title="{{ 'Compra rápida de' | translate }} {{ product.name }}" aria-label="{{ 'Compra rápida de' | translate }} {{ product.name }}">
                                            <span>{{ texts[state] | translate }}</span>
                                            <svg class="icon-inline ml-1"><use xlink:href="#bag-small"/></svg>
                                        </span>
                                    {% endif %}

                                {% else %}
                                    {% if product.variations %}

                                        {# Open quickshop popup if has variants #}

                                        <span data-toggle="#quickshop-modal" data-modal-url="modal-fullscreen-quickshop" class="js-quickshop-modal-open js-fullscreen-modal-open {% if slide_item %}js-quickshop-slide{% endif %} js-modal-open btn-link" title="{{ 'Compra rápida de' | translate }} {{ product.name }}" aria-label="{{ 'Compra rápida de' | translate }} {{ product.name }}" data-component="product-list-item.add-to-cart" data-component-value="{{product.id}}">
                                            <span class="js-open-quickshop-wording">{{ 'Comprar' | translate }}</span>
                                            <svg class="js-open-quickshop-icon icon-inline ml-1"><use xlink:href="#bag-small"/></svg>
                                        </span>
                                    {% else %}
                                        {# If not variants add directly to cart #}
                                        <form class="js-product-form" method="post" action="{{ store.cart_url }}">
                                            <input type="hidden" name="add_to_cart" value="{{product.id}}" />

                                            <div class="js-item-submit-container item-submit-container position-relative">
                                                <input type="submit" class="js-addtocart js-prod-submit-form btn-link btn-small-quickshop {{ state }}" value="{{ texts[state] | translate }}" alt="{{ texts[state] | translate }}" {% if state == 'nostock' %}disabled{% endif %} data-component="product-list-item.add-to-cart" data-component-value="{{ product.id }}"/>
                                                <svg class="js-quickshop-bag icon-inline item-quickshop-icon"><use xlink:href="#bag-small"/></svg>
                                            </div>

                                            {# Fake add to cart CTA visible during add to cart event #}

                                            {% include 'snipplets/placeholders/button-placeholder.tpl' with {direct_add: true} %}
                                        </form>
                                    {% endif %}
                                {% endif %}
                            </div>
                        {% endif %}
                    {% endif %}
                </a>
            </div>
            {% if (settings.quick_shop or settings.product_color_variants) and not reduced_item %}
                </div>{# This closes the quickshop tag #}
            {% endif %}

            {# Structured data to provide information for Google about the product content #}
            {{ component('structured-data', {'item': true}) }}
        </div>
    </div>
{% if slide_item %}
    </div>
{% endif %}