import React from 'react'
import ReactDom from 'react-dom'

import LeftNavPP from '../containers/LeftNavPP.jsx'
import AppBarPP from '../containers/AppBarPP.jsx'
import BodyPP from '../containers/BodyPP.jsx'

const App = () => (
  <div>
    <AppBarPP />
    <LeftNavPP />
		<BodyPP />
  </div>
)

export default App
