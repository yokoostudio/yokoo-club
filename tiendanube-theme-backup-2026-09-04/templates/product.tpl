<div id="single-product" class="js-has-new-shipping js-product-detail js-product-container js-shipping-calculator-container pb-4 pt-md-4 pb-md-3" data-variants="{{product.variants_object | json_encode }}" data-store="product-detail">
    {% set description_content = product.description is not empty or settings.show_product_fb_comment_box %}

    <div class="container mt-4 mt-md-0 mb-3 pt-md-1 {% if description_content and settings.full_width_description %}mb-md-0{% endif %}">
        <div class="row">
            <div class="col-md-7 pb-3 pr-md-2">
                {% include 'snipplets/product/product-image.tpl' %}
            </div>
            <div class="col" data-store="product-info-{{ product.id }}">
                {% include 'snipplets/product/product-form.tpl' %}
                {% if not settings.full_width_description %}
                    {% include 'snipplets/product/product-description.tpl' %}
                {% endif %}
            </div>
        </div>
        
        {# Product description full width #}

        {% if settings.full_width_description %}
            {% include 'snipplets/product/product-description.tpl' %}
        {% endif %}

        {# Product share #}
        
        <div class="text-center d-md-none">
            {% include 'snipplets/social/social-share.tpl' %}
        </div>
    </div>
</div>

{# Related products #}
{% include 'snipplets/product/product-related.tpl' %}