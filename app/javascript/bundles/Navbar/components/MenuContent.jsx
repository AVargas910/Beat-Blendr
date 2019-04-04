import React, { Component } from 'react'
import axios from 'axios'


class MenuContent extends Component {
  constructor(props) {
    super(props)
  }
   handleLogout = () => {
const link = document.createElement('a');
link.setAttribute('href', '/users/sign_out');
link.setAttribute('rel', 'nofollow');
link.setAttribute('data-method', 'delete');
document.body.appendChild(link);
link.click();
}

  render() {
    return (
      <div className="grandMenu">
        <div className="menu">
          <div className="signButton">
            <button id="signOutButton" onClick={this.handleLogout}>Sign Out</button>
          </div>
          <div className="textinsidepop">
            <p>Welcome!</p>
            <br/>
            <p>BeatBlendr lets you sample music based on nearby user preferences with just one click!</p>
            <br/>
            <p>Perfect for instant quick and easy party playlists.</p>
            <br/>
            <p>You can filter the BeatBlendr playlist generator to return danceable or relaxing music.</p>
            <br/>
            <p>If no users are logged in nearby, we will generate a playlist from our database so you can still sample some new music.</p>
            <br/>
            <p>To get started, just hit the Generate Playlist button!</p>
          </div>
        </div>
          <p className="hint">
          </p>
      </div>

    )
  }
}


export default MenuContent
