{# Main categories item demo #}

{% set main_category_view_box = '0 0 1000 1000' %}

<div class="swiper-slide w-md-auto">
	<div class="home-category text-center">
		<div class="home-category-image home-category-image-md home-category-image-placeholder">
			{% set help_item_path =  help_item_1 ? 'main-category-1' : help_item_2 ? 'main-category-2' : 'main-category-3'  %}
			<svg class="icon-inline svg-icon-text" viewBox="{{ main_category_view_box }}"><use xlink:href="#{{ help_item_path }}"/></svg>
		</div>
	</div>
</div>