describe('Acceptance Test', function () {
  beforeEach(function () {
    // before each test, we can automatically preserve the
    // 'session_id' and 'remember_token' cookies. this means they
    // will not be cleared before the NEXT test starts.
    //
    // the name of your cookies will likely be different
    // this is just a simple example
    Cypress.Cookies.debug(true)
    Cypress.Cookies.preserveOnce('_tradesway_key')
  })

  it('Can visit the users page', function () {
    cy.visit('http://localhost:5000/users')
  })

  it('Can hide the names column', function () {
    cy.contains('Bob')
    cy.get('[phx-value-column=name]').should('have.length', 2)
    cy.get('[phx-value-column=name]').first().click()
    cy.get('[phx-value-column=name]').should('not.exist')
    cy.contains('Bob').should('not.exist')
  })

  it('Can show the names column again', function () {
    cy.contains('Bob').should('not.exist');
    cy.contains('Show Name').should('not.exist')
    cy.contains('Show Field Buttons').first().click()
    cy.contains('Show Name').first().click()
    cy.contains('Bob')
  })

  it('Can search for names', function () {
    cy.contains('Sioban').should('not.exist')
    cy.get('input#search_search').type('siob')
    cy.contains('Sioban')
    cy.contains('21')
    cy.get('input#search_search').clear()
  })

  it('Can sort columns', function () {
    cy.contains('Bob')
    cy.contains('Sioban').should('not.exist')
    cy.contains('Nancy').should('not.exist')
    cy.contains('sort').first().click()
    cy.contains('Sioban').should('not.exist')
    cy.contains('Nancy')
    cy.contains('sort').first().click()
    cy.contains('Alan').should('not.exist')
    cy.contains('Sioban')
  })

  it('Can visit page 2', function () {
    cy.visit('http://localhost:5000/users')
    cy.contains('Bob')
    cy.contains('Sioban').should('not.exist')
    cy.contains('2').first().click()
    cy.contains('Sioban')
    cy.contains('Bob').should('not.exist')
  })

  it('Doesnt see the action column when there are no action buttons', function () {
    cy.visit('http://localhost:5000/posts/no_action_buttons')
    cy.contains('Posts')
    cy.contains('Actions').should('not.exist')
  })
})
