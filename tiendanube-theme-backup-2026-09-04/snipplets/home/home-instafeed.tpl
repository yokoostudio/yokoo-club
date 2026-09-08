{% if settings.show_instafeed and store.instagram and store.hasInstagramToken() %}
    <section class="section-instafeed-home overflow-none py-4" data-store="home-instagram-feed">
        <div class="container">
            {% set instuser = store.instagram|split('/')|last %}
            <a target="_blank" href="{{ store.instagram }}" class="mb-0" aria-label="{{ 'Instagram de' | translate }} {{ store.name }}">
                <div class="instafeed-title my-3 m-md-0 text-center">
                    <h2 class="h3 mt-3 mb-4">
                        <svg class="icon-inline mr-2 svg-icon-text"><use xlink:href="#instagram"/></svg>
                        {{ instuser }}
                    </h2>
                </div>
            </a>
            {% if store.hasInstagramToken() %}
                <div class="js-ig-success row row-grid"
                    data-ig-feed
                    data-ig-items-count="6"
                    data-ig-item-class="col-4 col-grid col-md-3 instafeed-col"
                    data-ig-link-class="instafeed-link"
                    data-ig-image-class="instafeed-img w-100 fade-in"
                    data-ig-aria-label="{{ 'Publicación de Instagram de' | translate }} {{ store.name }}"
                    style="display: none;">
                </div>
            {% endif %}
            <div class="text-center mb-3">
                <a target="_blank" href="{{ store.instagram }}" class="btn-link" aria-label="{{ 'Instagram de' | translate }} {{ store.name }}">{{ 'Ver perfil' | translate }}</a>
            </div>
        </div>
    </section>
{% endif %}