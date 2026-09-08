{# /*============================================================================
  #Page header
==============================================================================*/

#Properties

#Title

#Breadcrumbs

#}

{% set padding = padding ?? true %}
{% set container = container ?? true %}

{% if container %}
	<div class="container">
{% endif %}
		<section class="page-header {% if padding %}py-4{% endif %} text-center {{ page_header_class }}" data-store="page-title">
			{% include 'snipplets/breadcrumbs.tpl' %}
			{% if template == 'product' %}

				{{ component('nubesdk-slot', { type: "before_product_detail_name" }) }}

			{% endif %}
			<h1 class="{% if template == 'product' %}h2{% else %}h4{% endif %} {{ page_header_title_class }}" {% if template == "product" %}data-store="product-name-{{ product.id }}"{% endif %}>{% block page_header_text %}{% endblock %}</h1>
			{% if template == 'product' %}

				{{ component('nubesdk-slot', { type: "after_product_detail_name" }) }}

			{% endif %}
		</section>
{% if container %}
	</div>
{% endif %}
