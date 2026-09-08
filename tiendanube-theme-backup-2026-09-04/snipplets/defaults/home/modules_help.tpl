{# Modules that work as examples #}

<div class="js-module-banner-placeholder">
	<div class="container">
		<div class="textbanner mb-md-5 pb-md-5">
			<div class="row no-gutters align-items-center">
				<div class="col-md-6 textbanner-image overlay overflow-none textbanner-image-empty textbanner-image-empty-module">
				</div>
				<div class="col-md-6 px-3 px-md-4 textbanner-text">
					<div class="h3 mb-3">{{ module_title }}</div>
					<div class="textbanner-paragraph mb-3">{{ module_description }}</div>
				</div>
				<div class="placeholder-overlay transition-soft">
					<div class="placeholder-info">
						<svg class="icon-inline icon-3x"><use xlink:href="#edit"/></svg>
						<div class="placeholder-description font-small-xs">
							{{ help_text }} <strong>"{{ section_name }}"</strong>
						</div>
						{% if not params.preview %}
							<a href="{{ admin_link }}#instatheme=pagina-de-inicio" class="btn-primary btn btn-small placeholder-button">{{ "Editar" | translate }}</a>
						{% endif %}
					</div>
				</div>
			</div>
		</div>
		<div class="textbanner mb-md-5 pb-md-5">
			<div class="row no-gutters align-items-center">
				<div class="col-md-6 textbanner-image overlay overflow-none textbanner-image-empty textbanner-image-empty-module">
				</div>
				<div class="col-md-6 px-3 px-md-4 order-md-first textbanner-text">
					<div class="h3 mb-3">{{ module_title }}</div>
					<div class="textbanner-paragraph mb-3">{{ module_description }}</div>
				</div>
				<div class="placeholder-overlay transition-soft">
					<div class="placeholder-info">
						<svg class="icon-inline icon-3x"><use xlink:href="#edit"/></svg>
						<div class="placeholder-description font-small-xs">
							{{ help_text }} <strong>"{{ section_name }}"</strong>
						</div>
						{% if not params.preview %}
							<a href="{{ admin_link }}#instatheme=pagina-de-inicio" class="btn-primary btn btn-small placeholder-button">{{ "Editar" | translate }}</a>
						{% endif %}
					</div>
				</div>
			</div>
		</div>
	</div>
</div>

{# Skeleton of "true" section accessed from instatheme.js #}
<div class="js-module-banner-top" style="display:none">    
	{% include 'snipplets/home/home-banners.tpl' with {'has_module': true} %}
</div>