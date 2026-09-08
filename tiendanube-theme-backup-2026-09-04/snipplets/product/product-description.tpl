{% set description_content = product.description is not empty or settings.show_product_fb_comment_box %}

{{ component('nubesdk-slot', { type: "before_product_description" }) }}

{% if description_content %}
    <div class="mt-2 pb-md-4 text-center {% if settings.full_width_description %}mt-md-5 text-md-center{% else %}mt-md-3 text-md-left{% endif %}" data-store="product-description-{{ product.id }}">
        {# Product description #}

        {% if product.description is not empty %}
            <div class="user-content font-small mb-4">
                {{ product.description }}
            </div>
        {% endif %}

        {% if settings.show_product_fb_comment_box %}
            <div class="fb-comments section-fb-comments mb-3" data-href="{{ product.social_url }}" data-num-posts="5" data-width="100%"></div>
        {% endif %}
        <div id="reviewsapp"></div>
    </div>
{% endif %}

{{ component('nubesdk-slot', { type: "after_product_description" }) }}
