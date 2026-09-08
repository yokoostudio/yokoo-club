{% set has_filters_available = products and has_filters_enabled and (filter_categories is not empty or product_filters is not empty) %}

{# Only remove this if you want to take away the theme onboarding advices #}
{% set show_help = not has_products %}

{% if settings.pagination == 'infinite' %}
	{% paginate by 12 %}
{% else %}
	{% paginate by 24 %}
{% endif %}

{% if not show_help %}

{% set category_banner = (category.images is not empty) or ("banner-products.jpg" | has_custom_image) %}

<div class="container">
	{% embed "snipplets/page-header.tpl" with {container: false} %}
	    {% block page_header_text %}{{ category.name }}{% endblock page_header_text %}
	{% endembed %}
	{% if category_banner %}
	    {% include 'snipplets/category-banner.tpl' %}
	{% endif %}
	{% if category.description %}
		<p class="mt-2 mb-4 text-center">{{ category.description }}</p>
	{% endif %}
</div>

{% include 'snipplets/grid/filters-modals.tpl' %}
<section class="js-category-controls-prev category-controls-sticky-detector"></section>

<section class="category-body" data-store="category-grid-{{ category.id }}">
	<div class="container mt-4 mb-5">
		<div data-store="category-grid-{{ category.id }}">
			{% include 'snipplets/grid/product-list.tpl' %}
		</div>
	</div>
</section>
{% elseif show_help %}
	{# Category Placeholder #}
	{% include 'snipplets/defaults/show_help_category.tpl' %}
{% endif %}