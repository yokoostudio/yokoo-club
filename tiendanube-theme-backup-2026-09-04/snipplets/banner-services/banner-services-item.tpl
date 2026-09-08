<div class="swiper-slide col-auto col-md{% if num_banners_services == 1 %}-6 px-3 px-md-0{% endif %} p-0{% if loop.last %} mr-md-0{% endif %}">
    {% if banner_services_url %}
        <a href="{{ banner_services_url | setting_url }}">
    {% endif %}
    <div class="text-center">
        <div class="d-inline-block icon-60px mb-3">
            {% if banner_services_icon == 'image' and banner_services_image %}
                <img class="service-item-image lazyload" src="{{ 'images/empty-placeholder.png' | static_url }}" data-src='{{ "#{banner}.jpg" | static_url | settings_image_url("large") }}' {% if banner_services_title %}alt="{{ banner_services_title }}"{% else %}alt="{{ 'Banner de' | translate }} {{ store.name }}"{% endif %} />
            {% elseif banner_services_icon == 'shipping' %}
                <svg class="icon-inline icon-4x align-item-middle svg-icon-text"><use xlink:href="#box-alt"/></svg>
            {% elseif banner_services_icon == 'card' %}
                <svg class="icon-inline icon-4x align-item-middle svg-icon-text"><use xlink:href="#credit-card-alt"/></svg>
            {% elseif banner_services_icon == 'security' %}
                <svg class="icon-inline icon-4x align-item-middle svg-icon-text"><use xlink:href="#security"/></svg>
            {% elseif banner_services_icon == 'returns' %}
                <svg class="icon-inline icon-4x align-item-middle svg-icon-text"><use xlink:href="#returns"/></svg>
            {% elseif banner_services_icon == 'whatsapp' %}
                <svg class="icon-inline icon-4x align-item-middle svg-icon-text"><use xlink:href="#whatsapp-line"/></svg>
            {% elseif banner_services_icon == 'promotions' %}
                <svg class="icon-inline icon-4x align-item-middle svg-icon-text"><use xlink:href="#promotions"/></svg>
            {% elseif banner_services_icon == 'cash' %}
                <svg class="icon-inline icon-4x align-item-middle svg-icon-text"><use xlink:href="#cash"/></svg>
            {% endif %}
        </div>
        {% if banner_services_title %}
            <h3 class="mb-2">{{ banner_services_title }}</h3>
        {% endif %}
        {% if banner_services_description %}
            <p class="mb-2">{{ banner_services_description }}</p>
        {% endif %}
    </div>
    {% if banner_services_url %}
        </a>
    {% endif %}
</div>
