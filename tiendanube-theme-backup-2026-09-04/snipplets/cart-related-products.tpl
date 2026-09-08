{# Set related products classes #}

{% set title_class = 'h4 section-title mb-4 text-center' %}
{% set slider_container_class = 'swiper-container' %}
{% set swiper_wrapper_class = 'swiper-wrapper' %}
{% set slider_controls_container_class = 'text-center' %}
{% set slider_control_class = 'icon-inline icon-lg' %}
{% set slider_control_prev_class = 'swiper-button-prev' %}
{% set slider_control_next_class = 'swiper-button-next' %}
{% set control_next_svg_id = 'arrow-long' %}
{% set control_prev_svg_id = 'arrow-long' %}

{# Related cart products #}

{% set related_section_id = 'related-products-notification' %}

{% set related_products = related_products_list | length > 0 %}

{% if related_products %}
    {{ component(
        'products-section',{
        title: 'Sumá a tu compra' | translate,
        id: related_section_id,
        data_component: related_section_id,
        products_amount: related_products_list | length,
        products_array: related_products_list,
        product_template_path: 'snipplets/grid/item.tpl',
        product_template_params: {'slide_item': true, 'reduced_item': true},
        slider_controls_position: 'bottom',
        slider_controls_container: true,
        section_classes: {
            section: 'js-related-products-notification position-relative mt-4 pt-2',
            title: title_class,
            slider_container: 'js-swiper-related-products-notification ' ~ slider_container_class,
            slider_wrapper: swiper_wrapper_class,
            slider_controls_container: slider_controls_container_class,
            slider_control: slider_control_class,
            slider_control_prev_container: 'js-swiper-related-products-notification-prev ' ~ slider_control_prev_class,
            slider_control_prev: 'icon-flip-horizontal',
            slider_control_next_container: 'js-swiper-related-products-notification-next ' ~ slider_control_next_class,
        },
        control_next_svg_id: control_next_svg_id,
        control_prev_svg_id: control_prev_svg_id,
        })
    }}
{% endif %}
