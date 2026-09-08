{# Products featured that work as examples #}

<section class="section-featured-home" data-store="home-products-{{ section_id }}">
	<div class="container">
		<div class="row">
			<div class="col-12">
				<h2 class="js-products-{{ section_id }}-title section-title h3 mt-3 mb-4 pb-2 text-center">{{ products_title }}</h2>
				<div class="row row-grid">
					{% include 'snipplets/defaults/help_item.tpl' with {'help_item_1': true, 'section_columns_desktop': 4, 'section_columns_mobile': 2} %}
					{% include 'snipplets/defaults/help_item.tpl' with {'help_item_8': true, 'section_columns_desktop': 4, 'section_columns_mobile': 2} %}
					{% include 'snipplets/defaults/help_item.tpl' with {'help_item_4': true, 'section_columns_desktop': 4, 'section_columns_mobile': 2} %}
					{% include 'snipplets/defaults/help_item.tpl' with {'help_item_6': true, 'section_columns_desktop': 4, 'section_columns_mobile': 2} %}
				</div>
			</div>
		</div>
	</div>
</section>