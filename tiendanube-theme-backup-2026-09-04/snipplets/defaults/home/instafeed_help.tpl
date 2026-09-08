{# Instagram feed that work as examples #}

<section class="section-instafeed-home overflow-none pt-4 pb-5 position-relative" data-store="home-instagram-feed">
	<div class="container">
		<div class="instafeed-title my-3 m-md-0 text-center">
			<h2 class="h3 mt-3 mb-4">@{{ 'Instagram' | translate }}</h2>
		</div>
		<div id="instafeed" class="row row-grid">
			{% include 'snipplets/defaults/help_instagram.tpl' with {'help_item_1': true} %}
			{% include 'snipplets/defaults/help_instagram.tpl' with {'help_item_2': true} %}
			{% include 'snipplets/defaults/help_instagram.tpl' with {'help_item_1': true} %}
			{% include 'snipplets/defaults/help_instagram.tpl' with {'help_item_2': true} %}
			{% include 'snipplets/defaults/help_instagram.tpl' with {'help_item_1': true} %}
			{% include 'snipplets/defaults/help_instagram.tpl' with {'help_item_2': true} %}
		</div>
	</div>
	<div class="placeholder-overlay transition-soft">
		<div class="placeholder-info">
			<svg class="icon-inline icon-3x"><use xlink:href="#edit"/></svg>
			<div class="placeholder-description font-small-xs">
				{{ "Podés mostrar tus últimas novedades desde" | translate }} <strong>"{{ "Publicaciones de Instagram" | translate }}"</strong>
			</div>
			{% if not params.preview %}
				<a href="{{ admin_link }}#instatheme=pagina-de-inicio" class="btn-primary btn btn-small placeholder-button">{{ "Editar" | translate }}</a>
			{% endif %}
		</div>
	</div>
</section>