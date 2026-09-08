{% if settings.pagination == 'infinite' %}
	{% paginate by 12 %}
{% else %}
	{% paginate by 24 %}
{% endif %}

{% embed "snipplets/page-header.tpl" with { breadcrumbs: false, container: true } %}
	{% block page_header_text %}
		{% if products %}
			{{ 'Resultados de búsqueda' | translate }}
		{% else %}
			{{ "No encontramos nada para" | translate }}<span class="ml-2">"{{ query }}"</span>
		{% endif %}
	{% endblock page_header_text %}
{% endembed %}
{% if products %}
	<h2 class="h5 pb-2 font-weight-normal text-center {% if not search_filter %}mb-4{% endif %}">
		{{ "Mostrando los resultados para" | translate }}<span class="ml-2 font-weight-bold">"{{ query }}"</span>
	</h2>		
{% endif %}

{% include 'snipplets/grid/filters-modals.tpl' %}
<section class="js-category-controls-prev category-controls-sticky-detector"></section>

<section class="category-body overflow-none">
	<div class="container {% if search_filter and products %}mt-4{% endif %} mb-5">
		{% include 'snipplets/grid/product-list.tpl' %}
	</div>
</section>